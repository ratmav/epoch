-- tests/workflow/interval_spec.lua
-- Integration tests for complete interval workflows

local interval_workflow = require('epoch.workflow.interval')
local fixtures = require('fixtures')

describe("workflow interval", function()

  describe("add_interval workflow", function()
    it("should complete full interval creation workflow", function()
      local timesheet = fixtures.get('timesheets.valid.empty')
      local client = "acme-corp"
      local project = "website-redesign"  
      local task = "frontend-planning"

      local success, err, result = interval_workflow.add_interval(client, project, task, timesheet)

      assert.is_true(success)
      assert.is_nil(err)
      assert.is_table(result)
      assert.equals(1, #result.intervals)
      
      local new_interval = result.intervals[1]
      assert.equals(client, new_interval.client)
      assert.equals(project, new_interval.project)
      assert.equals(task, new_interval.task)
      assert.not_equals("", new_interval.start)
      assert.equals("", new_interval.stop)
      assert.is_table(new_interval.notes)
    end)

    it("should complete workflow with interval timing resolution", function()
      -- Timesheet with open interval - should close it and add new one
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')
      local original_interval_count = #timesheet.intervals
      
      local success, err, result = interval_workflow.add_interval("new-client", "new-project", "new-task", timesheet)

      assert.is_true(success)
      assert.is_nil(err)
      assert.equals(original_interval_count + 1, #result.intervals)
      
      -- Previous interval should be closed
      assert.not_equals("", result.intervals[1].stop)
      
      -- New interval should be added
      local new_interval = result.intervals[#result.intervals]
      assert.equals("new-client", new_interval.client)
      assert.equals("", new_interval.stop) -- New interval is open
    end)

    it("should complete workflow with daily total update", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      local original_total = timesheet.daily_total
      
      local success, err, result = interval_workflow.add_interval("test-client", "test-project", "test-task", timesheet)

      assert.is_true(success)
      assert.is_nil(err)
      -- Daily total should be recalculated
      assert.is_string(result.daily_total)
      assert.matches("^%d%d:%d%d$", result.daily_total)
    end)

    it("should handle validation failure workflow", function()
      local timesheet = fixtures.get('timesheets.valid.empty')
      
      -- Missing client
      local success, err, result = interval_workflow.add_interval("", "project", "task", timesheet)
      
      assert.is_false(success)
      assert.equals("client is required", err)
      assert.is_nil(result)
    end)

    it("should handle validation failure for missing project", function()
      local timesheet = fixtures.get('timesheets.valid.empty')
      
      local success, err, result = interval_workflow.add_interval("client", "", "task", timesheet)
      
      assert.is_false(success)
      assert.equals("project is required", err)
      assert.is_nil(result)
    end)

    it("should handle validation failure for missing task", function()
      local timesheet = fixtures.get('timesheets.valid.empty')
      
      local success, err, result = interval_workflow.add_interval("client", "project", "", timesheet)
      
      assert.is_false(success)
      assert.equals("task is required", err)
      assert.is_nil(result)
    end)

    it("should maintain immutability throughout workflow", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      local original_interval_count = #timesheet.intervals
      local original_total = timesheet.daily_total
      
      local success, err, result = interval_workflow.add_interval("test-client", "test-project", "test-task", timesheet)

      assert.is_true(success)
      -- Original timesheet should be unchanged
      assert.equals(original_interval_count, #timesheet.intervals)
      assert.equals(original_total, timesheet.daily_total)
      
      -- Result should be different object with changes
      assert.not_equals(timesheet, result)
      assert.equals(original_interval_count + 1, #result.intervals)
    end)
  end)
end)