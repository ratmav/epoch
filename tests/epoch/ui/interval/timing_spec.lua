-- ui_interval_timing_spec.lua
-- Test the ui/interval/timing module

describe("ui interval timing", function()
  local timing = require('epoch.ui.interval.timing')
  local fixtures = require('fixtures')

  describe("resolve_timing", function()
    it("should resolve timing for empty timesheet", function()
      local timesheet = fixtures.get("timesheets.valid.empty")
      local current_time = os.time()

      local adjusted_start, previous_stop = timing.resolve_timing(timesheet, current_time)

      assert.equals(current_time, adjusted_start)
      assert.is_nil(previous_stop)
    end)

    it("should handle unclosed interval timing conflict", function()
      local timesheet = fixtures.get("timesheets.valid.with_unclosed_intervals")
      local current_time = os.time()

      local adjusted_start, previous_stop = timing.resolve_timing(timesheet, current_time)

      assert.is_not_nil(adjusted_start)
      assert.is_not_nil(previous_stop)
    end)

    it("should handle closed interval without conflict", function()
      local timesheet = fixtures.get("timesheets.valid.with_intervals")
      -- Use a future timestamp that's definitely after any closed intervals
      local time_utils = require('epoch.time_utils')
      local last_interval = timesheet.intervals[#timesheet.intervals]
      local last_stop_timestamp = time_utils.parse_time(last_interval.stop)
      local future_time = last_stop_timestamp + 3600  -- 1 hour after last interval

      local adjusted_start, previous_stop = timing.resolve_timing(timesheet, future_time)

      -- When there's no conflict, should return the input time unchanged
      assert.equals(future_time, adjusted_start)
      assert.is_nil(previous_stop)
    end)
  end)
end)