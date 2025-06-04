-- validation_modules_spec.lua
-- Test the newly isolated validation modules

describe("validation modules", function()
  local interval_validator = require('epoch.validation.fields.interval')
  local timesheet_validator = require('epoch.validation.fields.timesheet')
  local context = require('epoch.validation.fields.context')

  -- Load fixtures

  describe("interval validation module", function()
    it("should validate complete valid intervals", function()
      local valid, err = interval_validator.validate(fixtures.get('intervals.valid.frontend'))

      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("should reject intervals with missing client", function()
      local valid, err = interval_validator.validate(fixtures.get('intervals.invalid.missing_client'))

      assert.is_false(valid)
      assert.matches("client cannot be empty", err)
    end)

    it("should reject intervals with missing project", function()
      local valid, err = interval_validator.validate(fixtures.get('intervals.invalid.missing_project'))

      assert.is_false(valid)
      assert.matches("project cannot be empty", err)
    end)

    it("should reject intervals with missing task", function()
      local valid, err = interval_validator.validate(fixtures.get('intervals.invalid.missing_task'))

      assert.is_false(valid)
      assert.matches("task cannot be empty", err)
    end)

    it("should reject intervals with invalid time format", function()
      local valid, err = interval_validator.validate(fixtures.get('intervals.invalid.invalid_time'))

      assert.is_false(valid)
      assert.matches("time.*format", err)
    end)

    it("should reject intervals with missing notes", function()
      local valid, err = interval_validator.validate(fixtures.get('intervals.invalid.missing_notes'))

      assert.is_false(valid)
      assert.matches("notes field is required", err)
    end)

    it("should reject intervals with invalid notes type", function()
      local valid, err = interval_validator.validate(fixtures.get('intervals.invalid.invalid_notes_type'))

      assert.is_false(valid)
      assert.matches("notes must be an array", err)
    end)

    it("should reject non-table inputs", function()
      local valid, err = interval_validator.validate("not a table")

      assert.is_false(valid)
      assert.matches("interval must be a table", err)
    end)

    it("should validate intervals with notes", function()
      local valid, err = interval_validator.validate(fixtures.get('intervals.valid.with_notes'))

      assert.is_true(valid)
      assert.is_nil(err)
    end)
  end)

  describe("timesheet validation module", function()
    it("should validate complete valid timesheets", function()
      local valid, err = timesheet_validator.validate(fixtures.get('timesheets.valid.with_intervals'))

      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("should validate empty timesheets", function()
      local valid, err = timesheet_validator.validate(fixtures.get('timesheets.valid.empty'))

      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("should reject timesheets with missing date", function()
      local valid, err = timesheet_validator.validate(fixtures.get('timesheets.invalid.missing_date'))

      assert.is_false(valid)
      assert.matches("missing date field", err)
    end)

    it("should reject timesheets with missing intervals", function()
      local valid, err = timesheet_validator.validate(fixtures.get('timesheets.invalid.missing_intervals'))

      assert.is_false(valid)
      assert.matches("intervals must be a table", err)
    end)

    it("should reject timesheets with invalid intervals", function()
      local valid, err = timesheet_validator.validate(fixtures.get('timesheets.invalid.invalid_interval'))

      assert.is_false(valid)
      assert.matches("invalid interval", err)
    end)

    it("should reject non-table inputs", function()
      local valid, err = timesheet_validator.validate("not a table")

      assert.is_false(valid)
      assert.matches("timesheet must be a table", err)
    end)

    it("should provide context for invalid intervals", function()
      local timesheet = fixtures.get('timesheets.invalid.invalid_interval')

      local valid, err = timesheet_validator.validate(timesheet)

      assert.is_false(valid)
      assert.matches("invalid interval at index 2", err)
      -- Should include context in error message
    end)
  end)

  describe("context generation module", function()
    it("should generate context for complete intervals", function()
      local interval_context = context.get_interval_context(fixtures.get('intervals.valid.frontend'))

      assert.equals("acme-corp/website-redesign/frontend-planning/09:00 AM", interval_context)
    end)

    it("should generate context for partial intervals", function()
      local partial_interval = fixtures.get('intervals.test.partial')

      local interval_context = context.get_interval_context(partial_interval)

      assert.equals("test-client/test-project", interval_context)
    end)

    it("should handle empty intervals", function()
      local interval_context = context.get_interval_context({})

      assert.equals("unknown interval", interval_context)
    end)

    it("should handle nil intervals", function()
      local interval_context = context.get_interval_context(nil)

      assert.equals("unknown interval", interval_context)
    end)

    it("should generate context with all fields", function()
      local complete_interval = fixtures.get('intervals.test.complete')

      local interval_context = context.get_interval_context(complete_interval)

      assert.equals("client/project/task/10:00 AM", interval_context)
    end)
  end)
end)