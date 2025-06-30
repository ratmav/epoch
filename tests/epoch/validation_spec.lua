-- validation_spec.lua
-- tests for the validation module

describe("validation", function()
  local validation = require('epoch.validation')


  describe("validate_timesheet", function()
    it("validates valid timesheets", function()
      -- Test each valid timesheet fixture
      for name, timesheet in pairs(fixtures.get('timesheets.valid')) do
        local is_valid, err = validation.validate_timesheet(timesheet)
        assert.is_true(is_valid, "Timesheet '" .. name .. "' should be valid, but got: " .. (err or ""))
      end
    end)

    it("rejects timesheets with missing date", function()
      local is_valid, err = validation.validate_timesheet(fixtures.get('timesheets.invalid.missing_date'))
      assert.is_false(is_valid)
      assert.truthy(err:match("missing date field"))
    end)

    it("rejects timesheets with missing intervals", function()
      local is_valid, err = validation.validate_timesheet(fixtures.get('timesheets.invalid.missing_intervals'))
      assert.is_false(is_valid)
      assert.truthy(err:match("intervals must be a table"))
    end)

    it("validates each interval within the timesheet", function()
      local is_valid, err = validation.validate_timesheet(fixtures.get('timesheets.invalid.invalid_interval'))
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
      local overlapping = fixtures.get('intervals.invalid.overlapping')
      local is_overlapping, msg = validation.check_overlapping_intervals(overlapping)

      assert.is_true(is_overlapping)
      assert.truthy(msg:match("intervals overlap"))
    end)

    it("detects when unclosed interval start time overlaps with existing interval", function()
      local overlapping_unclosed = fixtures.get('intervals.invalid.overlapping_unclosed')
      local is_overlapping, msg = validation.check_overlapping_intervals(overlapping_unclosed)

      assert.is_true(is_overlapping)
      assert.truthy(msg:match("intervals overlap"))
    end)

    it("accepts non-overlapping unclosed intervals", function()
      local non_overlapping_unclosed = fixtures.get('intervals.valid')
      local is_overlapping, _ = validation.check_overlapping_intervals(non_overlapping_unclosed)

      assert.is_false(is_overlapping)
    end)

    it("accepts non-overlapping intervals", function()
      local non_overlapping = fixtures.get('intervals.valid')
      local is_overlapping, _ = validation.check_overlapping_intervals(non_overlapping)

      assert.is_false(is_overlapping)
    end)

    it("handles empty or single intervals", function()
      local empty = {}
      local is_overlapping, _ = validation.check_overlapping_intervals(empty)
      assert.is_false(is_overlapping)

      local single = { fixtures.get('intervals.valid')[1] }
      is_overlapping, _ = validation.check_overlapping_intervals(single)
      assert.is_false(is_overlapping)
    end)
  end)
end)