-- epoch/report/week_utils/interval_calculation.lua
-- Interval time calculation utilities

local interval_calculation = {}
local time_utils = require('epoch.time_utils')

-- Validate interval has both start and stop times
local function is_complete_interval(interval)
  return interval.stop and interval.stop ~= ""
end

-- Get time values for interval calculation
local function get_interval_times(interval, date)
  local start_time = time_utils.time_to_seconds(interval.start, date)
  local stop_time = time_utils.time_to_seconds(interval.stop, date)

  if not start_time or not stop_time then
    return nil, nil
  end

  return start_time, stop_time
end

-- Calculate minutes between two time strings on the same day
function interval_calculation.calculate_interval_minutes(interval, date)
  if not is_complete_interval(interval) then
    return 0
  end

  local start_time, stop_time = get_interval_times(interval, date)
  if not start_time then
    return 0
  end

  local diff_seconds = stop_time - start_time
  return math.max(0, math.floor(diff_seconds / 60))
end

return interval_calculation