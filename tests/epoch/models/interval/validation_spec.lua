-- tests/epoch/models/interval/validation_spec.lua

local validation = require('epoch.models.interval.validation')

describe("models interval validation", function()
  describe("is_complete", function()
    it("should return true for interval with both start and stop times", function()
      local interval = fixtures.get('intervals.valid.frontend')

      local is_complete = validation.is_complete(interval)

      assert.is_true(is_complete)
    end)

    it("should return false for interval with empty stop time", function()
      local interval = fixtures.get('intervals.invalid.unclosed')

      local is_complete = validation.is_complete(interval)

      assert.is_false(is_complete)
    end)

    it("should return false for interval with invalid stop time", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "9:00 AM",
        stop = "invalid",
        notes = {}
      }

      local is_complete = validation.is_complete(interval)

      assert.is_false(is_complete)
    end)
  end)

  describe("validate", function()
    it("should validate complete valid interval", function()
      local interval = fixtures.get('intervals.valid.frontend')

      local is_valid, error_msg = validation.validate(interval)

      assert.is_true(is_valid)
      assert.is_nil(error_msg)
    end)

    it("should reject interval with missing client", function()
      local interval = fixtures.get('intervals.invalid.missing_client')

      local is_valid, error_msg = validation.validate(interval)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject interval with missing project", function()
      local interval = fixtures.get('intervals.invalid.missing_project')

      local is_valid, error_msg = validation.validate(interval)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject interval with missing task", function()
      local interval = fixtures.get('intervals.invalid.missing_task')

      local is_valid, error_msg = validation.validate(interval)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject interval with invalid notes", function()
      local interval = fixtures.get('intervals.invalid.invalid_notes_type')

      local is_valid, error_msg = validation.validate(interval)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)
  end)
end)
