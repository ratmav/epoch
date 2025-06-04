-- ui_workflow_spec.lua
-- Test the UI workflow module

describe("ui workflow", function()
  local workflow = require('epoch.ui.workflow')
  local fixtures = require('fixtures')

  describe("add_interval", function()
    it("should reject missing client", function()
      local timesheet = fixtures.get("timesheets.valid.empty")
      local success, error_msg, result = workflow.add_interval("", "project", "task", timesheet)

      assert.is_false(success)
      assert.equals("client is required", error_msg)
      assert.is_nil(result)
    end)

    it("should reject missing project", function()
      local timesheet = fixtures.get("timesheets.valid.empty")
      local success, error_msg, result = workflow.add_interval("client", "", "task", timesheet)

      assert.is_false(success)
      assert.equals("project is required", error_msg)
      assert.is_nil(result)
    end)

    it("should reject missing task", function()
      local timesheet = fixtures.get("timesheets.valid.empty")
      local success, error_msg, result = workflow.add_interval("client", "project", "", timesheet)

      assert.is_false(success)
      assert.equals("task is required", error_msg)
      assert.is_nil(result)
    end)

    it("should successfully add interval with valid inputs", function()
      local timesheet = fixtures.get("timesheets.valid.empty")
      local success, error_msg, result = workflow.add_interval("test-client", "test-project", "test-task", timesheet)

      assert.is_true(success)
      assert.is_nil(error_msg)
      assert.is_not_nil(result)
      assert.equals(1, #result.intervals)
      assert.equals("test-client", result.intervals[1].client)
      assert.equals("test-project", result.intervals[1].project)
      assert.equals("test-task", result.intervals[1].task)
    end)
  end)
end)