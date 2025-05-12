-- tests/ui/logic/workflow_spec.lua
-- Test workflow logic combining multiple operations

describe("ui logic workflow", function()
  local workflow_logic = require('epoch.ui.logic.workflow')

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
      local success, error_msg, updated_timesheet = workflow_logic.add_interval("client", "project", "task", timesheet)

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