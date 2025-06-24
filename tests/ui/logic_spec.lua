-- tests/ui/logic_spec.lua
-- Test the UI logic modules (pure testable logic)

describe("ui logic", function()
  local ui_logic = require('epoch.ui.logic')
  local timesheet_workflow = require('epoch.workflow.timesheet')
  local workflow_logic = require('epoch.ui.logic.workflow')
  local interval_calculation = require('epoch.interval.calculation')

  describe("timesheet logic", function()
    describe("validate_content", function()
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
        assert.matches("[cC]annot be empty", err)
      end)
    end)

    describe("update_daily_total", function()
      it("should update daily total based on intervals", function()
        local timesheet = fixtures.get('timesheets.valid.with_intervals')
        timesheet.daily_total = "00:00"

        local timesheet_calculation = require('epoch.timesheet.calculation')
        local updated = timesheet_calculation.update_daily_total(timesheet, interval_calculation.calculate_daily_total)

        assert.equals("00:00", timesheet.daily_total)
        assert.not_equals("00:00", updated.daily_total)
        assert.matches("^%d%d:%d%d$", updated.daily_total)
      end)
    end)
  end)

  describe("workflow logic", function()
    describe("add_interval", function()
      it("should reject missing client", function()
        local timesheet = fixtures.get('timesheets.valid.empty')
        local success, error_msg = workflow_logic.add_interval("", "project", "task", timesheet)

        assert.is_false(success)
        assert.equals("client is required", error_msg)
      end)

      it("should reject missing project", function()
        local timesheet = fixtures.get('timesheets.valid.empty')
        local success, error_msg = workflow_logic.add_interval("client", "", "task", timesheet)

        assert.is_false(success)
        assert.equals("project is required", error_msg)
      end)

      it("should reject missing task", function()
        local timesheet = fixtures.get('timesheets.valid.empty')
        local success, error_msg = workflow_logic.add_interval("client", "project", "", timesheet)

        assert.is_false(success)
        assert.equals("task is required", error_msg)
      end)

      it("should successfully add interval with valid inputs", function()
        local timesheet = fixtures.get('timesheets.valid.empty')
        local success, error_msg, updated_timesheet = workflow_logic.add_interval(
          "client", "project", "task", timesheet)

        assert.is_true(success)
        assert.is_nil(error_msg)
        assert.is_table(updated_timesheet)
        assert.equals(1, #updated_timesheet.intervals)
        assert.equals("client", updated_timesheet.intervals[1].client)
        assert.equals("project", updated_timesheet.intervals[1].project)
        assert.equals("task", updated_timesheet.intervals[1].task)
      end)
    end)
  end)

  describe("main logic module", function()
    it("should re-export timesheet validation", function()
      assert.is_function(ui_logic.validate_timesheet_content)
      assert.equals(timesheet_workflow.validate_content, ui_logic.validate_timesheet_content)
    end)

    it("should re-export daily total update", function()
      local timesheet_calculation = require('epoch.timesheet.calculation')
      assert.is_function(ui_logic.update_daily_total)
      assert.equals(timesheet_calculation.update_daily_total, ui_logic.update_daily_total)
    end)

    it("should re-export workflow add interval", function()
      assert.is_function(ui_logic.add_interval)
      assert.equals(workflow_logic.add_interval, ui_logic.add_interval)
    end)
  end)
end)