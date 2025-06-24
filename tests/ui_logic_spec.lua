-- ui_logic_spec.lua
-- Test the UI modules (timesheet, interval, workflow)

describe("ui modules", function()
  -- Load modules
  local interval_creation = require('epoch.interval.creation')
  local interval_calculation = require('epoch.interval.calculation')
  local timesheet_workflow = require('epoch.workflow.timesheet')
  local timesheet_calculation = require('epoch.timesheet.calculation')


  describe("timesheet validation", function()
    it("should validate correctly formatted timesheet content", function()
      local content = fixtures.get('ui.buffer_content.valid_timesheet')
      local timesheet, err = timesheet_workflow.validate_content(content)

      assert.is_nil(err)
      assert.is_table(timesheet)
      assert.equals("2025-05-12", timesheet.date)
      assert.equals(2, #timesheet.intervals)
    end)

    it("should reject malformed Lua syntax", function()
      local content = fixtures.get('ui.buffer_content.invalid_syntax')
      local timesheet, err = timesheet_workflow.validate_content(content)

      assert.is_nil(timesheet)
      assert.matches("lua syntax error", err)
    end)

    it("should reject content that isn't a table", function()
      local content = [[return "not a table"]]
      local timesheet, err = timesheet_workflow.validate_content(content)

      assert.is_nil(timesheet)
      assert.equals("timesheet must be a table", err)
    end)

    it("should reject invalid timesheet structure", function()
      local content = fixtures.get('ui.buffer_content.missing_field')
      local timesheet, err = timesheet_workflow.validate_content(content)

      assert.is_nil(timesheet)
      assert.is_string(err)
      -- Match various validation error patterns
      assert.matches("[cC]annot be empty", err)
    end)
  end)

  describe("interval operations", function()
    it("should create a valid interval with current time", function()
      local time_fixtures = require('fixtures.time_fixtures')
      local fixed_time = time_fixtures.timestamps.base_time

      local interval = interval_creation.create("acme-corp", "website-redesign", "frontend-planning", fixed_time)

      assert.equals("acme-corp", interval.client)
      assert.equals("website-redesign", interval.project)
      assert.equals("frontend-planning", interval.task)
      assert.not_equals("", interval.start)
      assert.equals("", interval.stop)
    end)

    it("should use provided time when specified", function()
      local custom_time = 1620100000 -- Different timestamp

      local interval = interval_creation.create("acme-corp", "website-redesign", "frontend-planning", custom_time)

      assert.equals("acme-corp", interval.client)
      assert.equals("website-redesign", interval.project)
      assert.equals("frontend-planning", interval.task)
      assert.not_equals("", interval.start)
      assert.equals("", interval.stop)
      assert.same({}, interval.notes)
    end)

    it("should initialize with empty notes array", function()
      local interval = interval_creation.create("acme-corp", "website-redesign", "frontend-planning")

      assert.is_table(interval.notes)
      assert.equals(0, #interval.notes)
    end)

  describe("close_current_interval", function()
    it("should close an open interval", function()
      -- Create a timesheet with an open interval using fixture
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')

      -- Close the interval
      local result = interval_creation.close_current(timesheet, "11:00 AM")

      assert.is_true(result)
      assert.equals("11:00 AM", timesheet.intervals[1].stop)
      assert.is_table(timesheet.intervals[1].notes)
    end)

    it("should ensure notes field exists when closing interval", function()
      -- Use a timesheet with an open interval that has no notes field
      local timesheet = fixtures.get('timesheets.invalid.with_unclosed_interval_no_notes')

      -- Close the interval
      local result = interval_creation.close_current(timesheet, "11:00 AM")

      assert.is_true(result)
      assert.equals("11:00 AM", timesheet.intervals[1].stop)
      assert.is_table(timesheet.intervals[1].notes)
      assert.equals(0, #timesheet.intervals[1].notes)
    end)

    it("should not modify already closed intervals", function()
      -- Use a timesheet with a closed interval
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      -- Original stop time
      local original_stop = timesheet.intervals[1].stop

      -- Try to close it again
      local result = interval_creation.close_current(timesheet, "12:00 PM")

      assert.is_false(result)
      assert.equals(original_stop, timesheet.intervals[1].stop)
    end)

    it("should handle empty timesheet", function()
      -- Use an empty timesheet
      local timesheet = fixtures.get('timesheets.valid.empty')

      -- Try to close nonexistent interval
      local result = interval_creation.close_current(timesheet)

      assert.is_false(result)
    end)
  end)

  describe("add_interval_to_timesheet", function()
    it("should add a new interval to timesheet", function()
      -- Use an empty timesheet
      local timesheet = fixtures.get('timesheets.valid.empty')

      -- Use an interval from fixture
      local interval = fixtures.get('intervals.valid.frontend')

      -- Add it to the timesheet
      local updated = timesheet_workflow.add_to_timesheet(timesheet, interval)

      assert.equals(1, #updated.intervals)
      assert.same(interval, updated.intervals[1])
    end)

    it("should close any open interval before adding new one", function()
      -- Create a timesheet with an unclosed interval
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')

      -- Add a new interval
      local new_interval = fixtures.get('intervals.valid.backend')

      -- Set a fixed stop time for predictable testing
      local stop_time = "10:30 AM"

      -- Mock close_current_interval to use our fixed stop time
      local original_close = interval_creation.close_current
      interval_creation.close_current = function(ts)
        ts.intervals[1].stop = stop_time
        return true
      end

      -- Add interval to timesheet
      local updated = timesheet_workflow.add_to_timesheet(timesheet, new_interval)

      -- Restore original function
      interval_creation.close_current = original_close

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
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      -- Calculate without relying on fixture's pre-calculated total
      timesheet.daily_total = "00:00" -- Reset to ensure we're calculating fresh

      local total = interval_calculation.calculate_daily_total(timesheet)

      -- The exact value depends on the intervals in the fixture
      -- but it should be a properly formatted time string
      assert.matches("^%d%d:%d%d$", total)
      assert.is_not.equals("00:00", total)
    end)

    it("should handle empty intervals list", function()
      -- Use empty timesheet from fixture
      local timesheet = fixtures.get('timesheets.valid.empty')

      local total = interval_calculation.calculate_daily_total(timesheet)

      assert.equals("00:00", total)
    end)

    it("should handle unclosed intervals", function()
      -- Use our fixture with only unclosed intervals
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')

      local total = interval_calculation.calculate_daily_total(timesheet)

      -- Unclosed intervals should not contribute to the total time
      assert.equals("00:00", total)
    end)
  end)

  describe("update_daily_total", function()
    it("should update daily total based on intervals", function()
      -- Use timesheet with intervals but reset its total
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      timesheet.daily_total = "00:00" -- Reset to ensure we're updating

      local updated = timesheet_calculation.update_daily_total(timesheet, interval_calculation.calculate_daily_total)

      -- Original should be unchanged
      assert.equals("00:00", timesheet.daily_total)

      -- Updated should have correct total based on intervals
      assert.not_equals("00:00", updated.daily_total)
      assert.matches("^%d%d:%d%d$", updated.daily_total)
    end)
  end)

  end)
end)