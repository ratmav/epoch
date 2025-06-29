-- tests/epoch/models/report/validation_spec.lua

local validation = require('epoch.models.report.validation')

describe("models report validation", function()
  describe("validate", function()
    it("should validate well-formed report", function()
      local report = {
        timesheets = {},
        summary = {},
        total_minutes = 0,
        dates = {},
        weeks = {}
      }

      local is_valid, error_msg = validation.validate(report)

      assert.is_true(is_valid)
      assert.is_nil(error_msg)
    end)

    it("should reject nil report", function()
      local is_valid, error_msg = validation.validate(nil)

      assert.is_false(is_valid)
      assert.equals("Report cannot be nil", error_msg)
    end)

    it("should reject report missing timesheets", function()
      local report = {
        summary = {},
        total_minutes = 0,
        dates = {},
        weeks = {}
      }

      local is_valid, error_msg = validation.validate(report)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject report missing summary", function()
      local report = {
        timesheets = {},
        total_minutes = 0,
        dates = {},
        weeks = {}
      }

      local is_valid, error_msg = validation.validate(report)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject report missing total_minutes", function()
      local report = {
        timesheets = {},
        summary = {},
        dates = {},
        weeks = {}
      }

      local is_valid, error_msg = validation.validate(report)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject report missing dates", function()
      local report = {
        timesheets = {},
        summary = {},
        total_minutes = 0,
        weeks = {}
      }

      local is_valid, error_msg = validation.validate(report)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject report missing weeks", function()
      local report = {
        timesheets = {},
        summary = {},
        total_minutes = 0,
        dates = {}
      }

      local is_valid, error_msg = validation.validate(report)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)
  end)
end)