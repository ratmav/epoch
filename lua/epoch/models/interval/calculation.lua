-- models/interval/calculation.lua
-- Interval calculation operations

local calculation = {}
local validation = require('epoch.models.interval.validation')
local time_service = require('epoch.services.time')

-- Check if interval has valid time formats
local function has_valid_times(this_interval)
  return time_service.is_valid_format(this_interval.start) and
         time_service.is_valid_format(this_interval.stop)
end

-- Private: calculate minutes between valid times
local function calculate_minutes_between(this_interval)
  local start_value = time_service.to_minutes_since_midnight(this_interval.start)
  local stop_value = time_service.to_minutes_since_midnight(this_interval.stop)

  if start_value and stop_value and stop_value > start_value then
    return stop_value - start_value
  end

  return 0
end

-- Calculate duration in minutes for completed intervals
function calculation.calculate_duration_minutes(this_interval)
  if not validation.is_complete(this_interval) then
    return 0
  end

  if not has_valid_times(this_interval) then
    return 0
  end

  return calculate_minutes_between(this_interval)
end

return calculation
