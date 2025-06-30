-- tests/validation/fields/timesheet_spec.lua

local validation = require('epoch.validation')

describe("validation fields timesheet", function()
  describe("validate_timesheet", function()
    it("validates valid timesheets", function()
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
end)