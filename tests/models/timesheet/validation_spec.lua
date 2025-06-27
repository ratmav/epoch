-- tests/models/timesheet/validation_spec.lua

local validation = require('models.timesheet.validation')

describe("models timesheet validation", function()
  describe("validate", function()
    it("should validate well-formed timesheet", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      local is_valid, error_msg = validation.validate(timesheet)

      assert.is_true(is_valid)
      assert.is_nil(error_msg)
    end)

    it("should validate empty timesheet", function()
      local timesheet = fixtures.get('timesheets.valid.empty')

      local is_valid, error_msg = validation.validate(timesheet)

      assert.is_true(is_valid)
      assert.is_nil(error_msg)
    end)

    it("should reject timesheet missing date", function()
      local timesheet = fixtures.get('timesheets.invalid.missing_date')

      local is_valid, error_msg = validation.validate(timesheet)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject timesheet missing intervals", function()
      local timesheet = fixtures.get('timesheets.invalid.missing_intervals')

      local is_valid, error_msg = validation.validate(timesheet)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject timesheet with invalid intervals", function()
      local timesheet = fixtures.get('timesheets.invalid.invalid_intervals')

      local is_valid, error_msg = validation.validate(timesheet)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)
  end)
end)
