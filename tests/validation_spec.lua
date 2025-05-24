-- validation_spec.lua
-- tests for the validation module

describe("validation", function()
  local validation = require('epoch.validation')
  local time_fixtures = require('tests.fixtures.time_fixtures')
  local interval_fixtures = require('tests.fixtures.interval_fixtures')
  local timesheet_fixtures = require('tests.fixtures.timesheet_fixtures')
  
  describe("validate_interval", function()
    it("validates valid intervals", function()
      for _, interval in ipairs(interval_fixtures.valid) do
        local is_valid, _ = validation.validate_interval(interval)
        assert.is_true(is_valid)
      end
    end)
    
    it("rejects intervals with missing client", function()
      local is_valid, err = validation.validate_interval(interval_fixtures.invalid.missing_client)
      assert.is_false(is_valid)
      assert.truthy(err:match("client cannot be empty"))
    end)
    
    it("rejects intervals with missing project", function()
      local is_valid, err = validation.validate_interval(interval_fixtures.invalid.missing_project)
      assert.is_false(is_valid)
      assert.truthy(err:match("project cannot be empty"))
    end)
    
    it("rejects intervals with missing task", function()
      local is_valid, err = validation.validate_interval(interval_fixtures.invalid.missing_task)
      assert.is_false(is_valid)
      assert.truthy(err:match("task cannot be empty"))
    end)
    
    it("rejects intervals with invalid time formats", function()
      local is_valid, err = validation.validate_interval(interval_fixtures.invalid.invalid_time)
      assert.is_false(is_valid)
      assert.truthy(err:match("must be in format"))
    end)
    
    it("handles non-table inputs gracefully", function()
      local is_valid, err = validation.validate_interval(nil)
      assert.is_false(is_valid)
      assert.truthy(err:match("interval must be a table"))
      
      is_valid, err = validation.validate_interval("not a table")
      assert.is_false(is_valid)
      assert.truthy(err:match("interval must be a table"))
    end)
  end)
  
  describe("validate_timesheet", function()
    it("validates valid timesheets", function()
      -- Test each valid timesheet fixture
      for name, timesheet in pairs(timesheet_fixtures.valid) do
        local is_valid, err = validation.validate_timesheet(timesheet)
        assert.is_true(is_valid, "Timesheet '" .. name .. "' should be valid, but got: " .. (err or ""))
      end
    end)
    
    it("rejects timesheets with missing date", function()
      local is_valid, err = validation.validate_timesheet(timesheet_fixtures.invalid.missing_date)
      assert.is_false(is_valid)
      assert.truthy(err:match("missing date field"))
    end)
    
    it("rejects timesheets with missing intervals", function()
      local is_valid, err = validation.validate_timesheet(timesheet_fixtures.invalid.missing_intervals)
      assert.is_false(is_valid)
      assert.truthy(err:match("intervals must be a table"))
    end)
    
    it("validates each interval within the timesheet", function()
      local is_valid, err = validation.validate_timesheet(timesheet_fixtures.invalid.invalid_interval)
      assert.is_false(is_valid)
      assert.truthy(err:match("invalid interval at index"))
    end)
    
    it("handles non-table inputs gracefully", function()
      local is_valid, err = validation.validate_timesheet(nil)
      assert.is_false(is_valid)
      assert.truthy(err:match("timesheet must be a table"))
      
      is_valid, err = validation.validate_timesheet("not a table")
      assert.is_false(is_valid)
      assert.truthy(err:match("timesheet must be a table"))
    end)
  end)
  
  describe("check_overlapping_intervals", function()
    it("detects overlapping intervals", function()
      local overlapping = interval_fixtures.invalid.overlapping
      local is_overlapping, msg = validation.check_overlapping_intervals(overlapping)
      
      assert.is_true(is_overlapping)
      assert.truthy(msg:match("intervals overlap"))
    end)
    
    it("detects when unclosed interval start time overlaps with existing interval", function()
      local overlapping_unclosed = interval_fixtures.invalid.overlapping_unclosed
      local is_overlapping, msg = validation.check_overlapping_intervals(overlapping_unclosed)
      
      assert.is_true(is_overlapping)
      assert.truthy(msg:match("intervals overlap"))
    end)
    
    it("accepts non-overlapping unclosed intervals", function()
      local non_overlapping_unclosed = interval_fixtures.invalid.non_overlapping_unclosed
      local is_overlapping, _ = validation.check_overlapping_intervals(non_overlapping_unclosed)
      
      assert.is_false(is_overlapping)
    end)
    
    it("accepts non-overlapping intervals", function()
      local non_overlapping = interval_fixtures.valid
      local is_overlapping, _ = validation.check_overlapping_intervals(non_overlapping)
      
      assert.is_false(is_overlapping)
    end)
    
    it("handles empty or single intervals", function()
      local empty = {}
      local is_overlapping, _ = validation.check_overlapping_intervals(empty)
      assert.is_false(is_overlapping)
      
      local single = { interval_fixtures.valid[1] }
      is_overlapping, _ = validation.check_overlapping_intervals(single)
      assert.is_false(is_overlapping)
    end)
  end)
end)