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

    it("should close previous open interval when adding new interval", function()
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')
      local success, error_msg, updated_timesheet = workflow_logic.add_interval(
        "client2", "project2", "task2", timesheet
      )

      assert.is_true(success)
      assert.is_nil(error_msg)
      assert.is_table(updated_timesheet)
      assert.equals(2, #updated_timesheet.intervals)

      -- First interval should now be closed (stop time should not be empty)
      assert.is_not_equal("", updated_timesheet.intervals[1].stop)
      assert.is_string(updated_timesheet.intervals[1].stop)

      -- Second interval should be open (newly created)
      assert.equals("", updated_timesheet.intervals[2].stop)
      assert.equals("client2", updated_timesheet.intervals[2].client)
      assert.equals("project2", updated_timesheet.intervals[2].project)
      assert.equals("task2", updated_timesheet.intervals[2].task)
    end)
  end)
end)