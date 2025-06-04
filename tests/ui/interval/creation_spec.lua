-- ui_interval_creation_spec.lua
-- Test the ui/interval/creation module

describe("ui interval creation", function()
  local creation = require('epoch.ui.interval.creation')
  local fixtures = require('fixtures')

  describe("create", function()
    it("should create interval with default time", function()
      local interval = creation.create("test-client", "test-project", "test-task")

      assert.equals("test-client", interval.client)
      assert.equals("test-project", interval.project)
      assert.equals("test-task", interval.task)
      assert.is_not_nil(interval.start)
      assert.equals("", interval.stop)
      assert.same({}, interval.notes)
    end)

    it("should create interval with specified time", function()
      local test_time = os.time()
      local interval = creation.create("client", "project", "task", test_time)

      -- Should format the time
      assert.is_not_nil(interval.start)
      assert.is_string(interval.start)
    end)
  end)

  describe("close_current", function()
    it("should close current interval when one exists", function()
      local timesheet = fixtures.get("timesheets.valid.with_unclosed_intervals")

      local result = creation.close_current(timesheet, "11:00 AM")

      assert.is_true(result)
      assert.equals("11:00 AM", timesheet.intervals[1].stop)
    end)

    it("should not close already closed intervals", function()
      local timesheet = fixtures.get("timesheets.valid.with_intervals")

      local result = creation.close_current(timesheet, "11:00 AM")

      assert.is_false(result)
    end)

    it("should handle empty timesheet gracefully", function()
      local timesheet = fixtures.get("timesheets.valid.empty")

      local result = creation.close_current(timesheet, "11:00 AM")

      assert.is_false(result)
    end)
  end)
end)