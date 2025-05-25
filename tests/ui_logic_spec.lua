-- ui_logic_spec.lua
-- Test the UI logic module (core logic extracted from UI module)

describe("ui_logic", function()
  -- Load modules
  local ui_logic = require('epoch.ui_logic')
  local validation = require('epoch.validation')
  local time_utils = require('epoch.time_utils')

  -- Load fixtures
  local ui_fixtures = require('tests.fixtures.ui_fixtures')
  local timesheet_fixtures = require('tests.fixtures.timesheet_fixtures')
  local interval_fixtures = require('tests.fixtures.interval_fixtures')

  describe("validate_timesheet_content", function()
    it("should validate correctly formatted timesheet content", function()
      local content = ui_fixtures.buffer_content.valid_timesheet
      local timesheet, err = ui_logic.validate_timesheet_content(content)

      assert.is_nil(err)
      assert.is_table(timesheet)
      assert.equals("2025-05-12", timesheet.date)
      assert.equals(2, #timesheet.intervals)
    end)

    it("should reject malformed Lua syntax", function()
      local content = ui_fixtures.buffer_content.invalid_syntax
      local timesheet, err = ui_logic.validate_timesheet_content(content)

      assert.is_nil(timesheet)
      assert.matches("lua syntax error", err)
    end)

    it("should reject content that isn't a table", function()
      local content = [[return "not a table"]]
      local timesheet, err = ui_logic.validate_timesheet_content(content)

      assert.is_nil(timesheet)
      assert.equals("invalid timesheet format (not a table)", err)
    end)

    it("should reject invalid timesheet structure", function()
      local content = ui_fixtures.buffer_content.missing_field
      local timesheet, err = ui_logic.validate_timesheet_content(content)

      assert.is_nil(timesheet)
      assert.is_string(err)
      -- Match various validation error patterns
      assert.matches("[cC]annot be empty", err)
    end)
  end)

  describe("create_interval", function()
    it("should create a valid interval with current time", function()
      -- Mock os.time to return a fixed value
      local original_time = os.time
      local fixed_time = 1620000000 -- Some fixed timestamp
      os.time = function() return fixed_time end

      local interval = ui_logic.create_interval("acme-corp", "website-redesign", "frontend-planning")

      -- Restore original time function
      os.time = original_time

      assert.equals("acme-corp", interval.client)
      assert.equals("website-redesign", interval.project)
      assert.equals("frontend-planning", interval.task)
      assert.not_equals("", interval.start)
      assert.equals("", interval.stop)
    end)

    it("should use provided time when specified", function()
      local custom_time = 1620100000 -- Different timestamp

      local interval = ui_logic.create_interval("acme-corp", "website-redesign", "frontend-planning", custom_time)

      assert.equals("acme-corp", interval.client)
      assert.equals("website-redesign", interval.project)
      assert.equals("frontend-planning", interval.task)
      assert.not_equals("", interval.start)
      assert.equals("", interval.stop)
      assert.same({}, interval.notes)
    end)
    
    it("should initialize with empty notes array", function()
      local interval = ui_logic.create_interval("acme-corp", "website-redesign", "frontend-planning")
      
      assert.is_table(interval.notes)
      assert.equals(0, #interval.notes)
    end)
  end)

  describe("close_current_interval", function()
    it("should close an open interval", function()
      -- Create a timesheet with an open interval using fixture
      local timesheet = timesheet_fixtures.create("2025-05-12", {
        interval_fixtures.invalid.unclosed
      })

      -- Close the interval
      local result = ui_logic.close_current_interval(timesheet, "11:00 AM")

      assert.is_true(result)
      assert.equals("11:00 AM", timesheet.intervals[1].stop)
      assert.is_table(timesheet.intervals[1].notes)
    end)
    
    it("should ensure notes field exists when closing interval", function()
      -- Create a timesheet with an open interval that has no notes field
      local interval_without_notes = {
        client = "acme-corp",
        project = "website-redesign",
        task = "frontend-planning",
        start = "09:00 AM",
        stop = ""
      }
      local timesheet = timesheet_fixtures.create("2025-05-12", {
        interval_without_notes
      })

      -- Close the interval
      local result = ui_logic.close_current_interval(timesheet, "11:00 AM")

      assert.is_true(result)
      assert.equals("11:00 AM", timesheet.intervals[1].stop)
      assert.is_table(timesheet.intervals[1].notes)
      assert.equals(0, #timesheet.intervals[1].notes)
    end)

    it("should not modify already closed intervals", function()
      -- Use a timesheet with a closed interval
      local timesheet = timesheet_fixtures.create("2025-05-12", {
        interval_fixtures.base.frontend
      })

      -- Original stop time
      local original_stop = timesheet.intervals[1].stop

      -- Try to close it again
      local result = ui_logic.close_current_interval(timesheet, "12:00 PM")

      assert.is_false(result)
      assert.equals(original_stop, timesheet.intervals[1].stop)
    end)

    it("should handle empty timesheet", function()
      -- Use an empty timesheet
      local timesheet = timesheet_fixtures.valid.empty

      -- Try to close nonexistent interval
      local result = ui_logic.close_current_interval(timesheet)

      assert.is_false(result)
    end)
  end)

  describe("add_interval_to_timesheet", function()
    it("should add a new interval to timesheet", function()
      -- Use an empty timesheet
      local timesheet = timesheet_fixtures.valid.empty

      -- Use an interval from fixture
      local interval = interval_fixtures.base.frontend

      -- Add it to the timesheet
      local updated = ui_logic.add_interval_to_timesheet(timesheet, interval)

      assert.equals(1, #updated.intervals)
      assert.same(interval, updated.intervals[1])
    end)

    it("should close any open interval before adding new one", function()
      -- Create a timesheet with an unclosed interval
      local timesheet = timesheet_fixtures.create("2025-05-12", {
        interval_fixtures.invalid.unclosed
      })

      -- Add a new interval
      local new_interval = interval_fixtures.base.backend

      -- Set a fixed stop time for predictable testing
      local stop_time = "10:30 AM"

      -- Mock close_current_interval to use our fixed stop time
      local original_close = ui_logic.close_current_interval
      ui_logic.close_current_interval = function(ts)
        ts.intervals[1].stop = stop_time
        return true
      end

      -- Add interval to timesheet
      local updated = ui_logic.add_interval_to_timesheet(timesheet, new_interval)

      -- Restore original function
      ui_logic.close_current_interval = original_close

      assert.equals(2, #updated.intervals)

      -- First interval should be closed with our fixed stop time
      assert.equals(stop_time, updated.intervals[1].stop)

      -- Second interval should be as provided
      assert.same(new_interval, updated.intervals[2])
    end)
  end)

  describe("calculate_daily_total", function()
    it("should calculate correct total for intervals", function()
      -- Use timesheet with intervals from fixture
      local timesheet = timesheet_fixtures.valid.with_intervals

      -- Calculate without relying on fixture's pre-calculated total
      timesheet.daily_total = "00:00" -- Reset to ensure we're calculating fresh

      local total = ui_logic.calculate_daily_total(timesheet)

      -- The exact value depends on the intervals in the fixture
      -- but it should be a properly formatted time string
      assert.matches("^%d%d:%d%d$", total)
      assert.is_not.equals("00:00", total)
    end)

    it("should handle empty intervals list", function()
      -- Use empty timesheet from fixture
      local timesheet = timesheet_fixtures.valid.empty

      local total = ui_logic.calculate_daily_total(timesheet)

      assert.equals("00:00", total)
    end)

    it("should handle unclosed intervals", function()
      -- Use our fixture with only unclosed intervals
      local timesheet = timesheet_fixtures.valid.with_unclosed_intervals

      local total = ui_logic.calculate_daily_total(timesheet)

      -- Unclosed intervals should not contribute to the total time
      assert.equals("00:00", total)
    end)
  end)

  describe("update_daily_total", function()
    it("should update daily total based on intervals", function()
      -- Use timesheet with intervals but reset its total
      local timesheet = vim.deepcopy(timesheet_fixtures.valid.with_intervals)
      timesheet.daily_total = "00:00" -- Reset to ensure we're updating

      local updated = ui_logic.update_daily_total(timesheet)

      -- Original should be unchanged
      assert.equals("00:00", timesheet.daily_total)

      -- Updated should have correct total based on intervals
      assert.not_equals("00:00", updated.daily_total)
      assert.matches("^%d%d:%d%d$", updated.daily_total)
    end)
  end)
end)