-- tests/ui/logic/timesheet_spec.lua
-- Test timesheet validation and manipulation logic

describe("ui logic timesheet", function()
  local timesheet_logic = require('epoch.ui.logic.timesheet')
  local interval_ops = require('epoch.ui.interval')

  describe("validate_content", function()
    it("should validate correctly formatted timesheet content", function()
      local content = fixtures.get('ui.buffer_content.valid_timesheet')
      local timesheet, err = timesheet_logic.validate_content(content)

      assert.is_nil(err)
      assert.is_table(timesheet)
      assert.equals("2025-05-12", timesheet.date)
      assert.equals(2, #timesheet.intervals)
    end)

    it("should reject malformed Lua syntax", function()
      local content = fixtures.get('ui.buffer_content.invalid_syntax')
      local timesheet, err = timesheet_logic.validate_content(content)

      assert.is_nil(timesheet)
      assert.matches("lua syntax error", err)
    end)

    it("should reject content that isn't a table", function()
      local content = [[return "not a table"]]
      local timesheet, err = timesheet_logic.validate_content(content)

      assert.is_nil(timesheet)
      assert.equals("invalid timesheet format (not a table)", err)
    end)

    it("should reject invalid timesheet structure", function()
      local content = fixtures.get('ui.buffer_content.missing_field')
      local timesheet, err = timesheet_logic.validate_content(content)

      assert.is_nil(timesheet)
      assert.is_string(err)
      assert.matches("[cC]annot be empty", err)
    end)
  end)

  describe("update_daily_total", function()
    it("should update daily total based on intervals", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      timesheet.daily_total = "00:00"

      local updated = timesheet_logic.update_daily_total(timesheet, interval_ops.calculate_daily_total)

      assert.equals("00:00", timesheet.daily_total)
      assert.not_equals("00:00", updated.daily_total)
      assert.matches("^%d%d:%d%d$", updated.daily_total)
    end)
  end)
end)