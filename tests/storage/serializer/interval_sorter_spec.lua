-- tests/storage/serializer/interval_sorter_spec.lua

local interval_sorter = require('epoch.storage.serializer.interval_sorter')

describe("storage serializer interval_sorter", function()
  describe("sort_intervals", function()
    it("sorts intervals by start time", function()
      local timesheet = fixtures.get('timesheets.valid.unsorted_intervals')
      local sorted = interval_sorter.sort_intervals(timesheet)

      assert.equals("09:00 AM", sorted.intervals[1].start)
      assert.equals("10:45 AM", sorted.intervals[2].start)
    end)

    it("handles timesheets with no intervals", function()
      local timesheet = fixtures.get('timesheets.valid.empty')
      local sorted = interval_sorter.sort_intervals(timesheet)

      assert.same({}, sorted.intervals)
    end)

    it("handles timesheets with single interval", function()
      local timesheet = fixtures.get('timesheets.storage.single_interval')

      local sorted = interval_sorter.sort_intervals(timesheet)
      assert.equals(1, #sorted.intervals)
      assert.equals("9:00 AM", sorted.intervals[1].start)
    end)

    it("handles intervals with missing start times", function()
      local timesheet = fixtures.get('timesheets.storage.mixed_intervals')

      local sorted = interval_sorter.sort_intervals(timesheet)
      assert.equals("9:00 AM", sorted.intervals[1].start)
      assert.is_nil(sorted.intervals[2].start)
    end)
  end)
end)