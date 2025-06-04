-- ui/timesheet_spec.lua
-- Test the ui/timesheet module business logic

describe("ui timesheet", function()
  local timesheet = require('epoch.ui.timesheet')
  local fixtures = require('fixtures')

  describe("validate_content", function()
    it("should validate correctly formatted timesheet content", function()
      local content = fixtures.get('ui.buffer_content.valid_timesheet')
      local result, err = timesheet.validate_content(content)

      assert.is_nil(err)
      assert.is_table(result)
      assert.equals("2025-05-12", result.date)
    end)

    it("should reject malformed Lua syntax", function()
      local malformed_content = "return { invalid syntax"
      local result, err = timesheet.validate_content(malformed_content)

      assert.is_nil(result)
      assert.is_string(err)
      assert.matches("lua syntax error", err)
    end)

    it("should reject content that isn't a table", function()
      local non_table_content = "return 'not a table'"
      local result, err = timesheet.validate_content(non_table_content)

      assert.is_nil(result)
      assert.is_string(err)
      assert.matches("invalid timesheet format", err)
    end)

    it("should reject invalid timesheet structure", function()
      local invalid_content = "return { invalid = 'structure' }"
      local result, err = timesheet.validate_content(invalid_content)

      assert.is_nil(result)
      assert.is_string(err)
    end)
  end)

  describe("update_daily_total", function()
    it("should update daily total using provided calculation function", function()
      local timesheet_data = fixtures.get("timesheets.valid.with_intervals")

      -- update_daily_total sends a timesheet, which is unused
      local calc_fn = function(_) return "02:30" end

      local updated = timesheet.update_daily_total(timesheet_data, calc_fn)

      assert.equals("02:30", updated.daily_total)
      -- Original should not be modified
      assert.is_not.equals("02:30", timesheet_data.daily_total)
    end)
  end)
end)