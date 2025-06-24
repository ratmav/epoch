-- ui/interval_spec.lua
-- Tests for ui interval module

local interval_creation = require('epoch.interval.creation')
local timesheet_workflow = require('epoch.workflow.timesheet')
local factory = require('epoch.factory')

describe('ui interval', function()
  describe('add_to_timesheet', function()
    it('should add interval to empty timesheet', function()
      local timesheet = factory.build_timesheet()
      local new_interval = factory.build_interval({
        start = "09:00",
        stop = "10:00"
      })

      local result = timesheet_workflow.add_to_timesheet(timesheet, new_interval)

      assert.equals(1, #result.intervals)
      assert.equals("09:00", result.intervals[1].start)
      assert.equals("10:00", result.intervals[1].stop)
    end)

    it('should close existing open interval before adding new one', function()
      local existing_interval = factory.build_interval({
        start = "08:00"
        -- No stop time - open interval
      })
      local timesheet = factory.build_timesheet({
        intervals = { existing_interval }
      })
      local new_interval = factory.build_interval({
        start = "10:00",
        stop = "11:00"
      })

      local result = timesheet_workflow.add_to_timesheet(timesheet, new_interval)

      assert.equals(2, #result.intervals)
      -- First interval should now be closed
      assert.is_not_nil(result.intervals[1].stop)
      -- Second interval should be the new one
      assert.equals("10:00", result.intervals[2].start)
      assert.equals("11:00", result.intervals[2].stop)
    end)

    it('should not modify original timesheet', function()
      local timesheet = factory.build_timesheet()
      local original_count = #timesheet.intervals
      local new_interval = factory.build_interval()

      timesheet_workflow.add_to_timesheet(timesheet, new_interval)

      -- Original timesheet should be unchanged
      assert.equals(original_count, #timesheet.intervals)
    end)

    it('should preserve existing closed intervals', function()
      local existing_interval = factory.build_interval({
        start = "08:00",
        stop = "09:00"
      })
      local timesheet = factory.build_timesheet({
        intervals = { existing_interval }
      })
      local new_interval = factory.build_interval({
        start = "10:00",
        stop = "11:00"
      })

      local result = timesheet_workflow.add_to_timesheet(timesheet, new_interval)

      assert.equals(2, #result.intervals)
      -- First interval should remain unchanged
      assert.equals("08:00", result.intervals[1].start)
      assert.equals("09:00", result.intervals[1].stop)
      -- Second interval should be the new one
      assert.equals("10:00", result.intervals[2].start)
    end)
  end)
end)