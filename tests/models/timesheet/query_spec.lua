-- tests/models/timesheet/query_spec.lua

local query = require('models.timesheet.query')

describe("models timesheet query", function()
  describe("has_open_interval", function()
    it("should return true when timesheet has open intervals", function()
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')

      local has_open = query.has_open_interval(timesheet)

      assert.is_true(has_open)
    end)

    it("should return false when all intervals are closed", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      local has_open = query.has_open_interval(timesheet)

      assert.is_false(has_open)
    end)

    it("should return false for empty timesheet", function()
      local timesheet = fixtures.get('timesheets.valid.empty')

      local has_open = query.has_open_interval(timesheet)

      assert.is_false(has_open)
    end)
  end)

  describe("get_completed_intervals", function()
    it("should return only completed intervals", function()
      local timesheet = fixtures.get('timesheets.valid.mixed_intervals')

      local completed = query.get_completed_intervals(timesheet)

      assert.equals(2, #completed)
      -- All returned intervals should be complete
      for _, interval in ipairs(completed) do
        assert.is_not_equal("", interval.stop)
      end
    end)

    it("should return empty array for timesheet with no completed intervals", function()
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')

      local completed = query.get_completed_intervals(timesheet)

      assert.same({}, completed)
    end)

    it("should return all intervals when all are completed", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      local completed = query.get_completed_intervals(timesheet)

      assert.equals(#timesheet.intervals, #completed)
    end)
  end)
end)
