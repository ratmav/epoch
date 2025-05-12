-- epoch/ui/interval/calculation.lua
-- Duration calculation utilities

local time_utils = require('epoch.time_utils')
local validation = require('epoch.validation')

local calculation = {}

-- Validate timesheet input for calculation
local function validate_timesheet_input(timesheet)
  if not timesheet or not timesheet.intervals then
    return false
  end
  return true
end

-- Check if interval has both start and stop times
local function is_complete_interval(interval)
  return interval.start and interval.stop and interval.stop ~= ""
end

-- Calculate minutes for a single interval
local function calculate_interval_minutes(interval)
  if not time_utils.is_valid_time_format(interval.start) or not time_utils.is_valid_time_format(interval.stop) then
    return 0
  end

  local start_value = validation.time_value(interval.start)
  local stop_value = validation.time_value(interval.stop)

  if start_value and stop_value and stop_value > start_value then
    return math.floor((stop_value - start_value) / 60)
  end

  return 0
end

-- Calculate daily total duration from intervals
-- Returns: formatted duration string (HH:MM)
function calculation.calculate_daily_total(timesheet)
  if not validate_timesheet_input(timesheet) then
    return "00:00"
  end

  local total_minutes = 0
  for _, current_interval in ipairs(timesheet.intervals) do
    if is_complete_interval(current_interval) then
      total_minutes = total_minutes + calculate_interval_minutes(current_interval)
    end
  end

  return time_utils.format_duration(total_minutes)
end

return calculation