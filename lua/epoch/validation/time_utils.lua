-- epoch/validation/time_utils.lua
-- Time value parsing utilities for validation

local time_utils = {}

-- Parse time string components
local function parse_time_string(time_str)
  if not time_str or time_str == "" then
    return nil
  end

  local hour, minute, period = time_str:match("^(%d+):(%d+)%s*([AP]M)$")
  if not hour or not minute or not period then
    return nil
  end

  return tonumber(hour), tonumber(minute), period
end

-- Validate time component ranges
local function validate_time_ranges(hour, minute)
  return hour >= 1 and hour <= 12 and minute >= 0 and minute <= 59
end

-- Convert 12-hour to 24-hour format
local function convert_to_24_hour(hour, period)
  if period == "AM" then
    return hour == 12 and 0 or hour
  else -- PM
    return hour == 12 and 12 or hour + 12
  end
end

-- Convert time string to minutes since midnight for comparison
function time_utils.time_value(time_str)
  local hour, minute, period = parse_time_string(time_str)
  if not hour then return nil end

  if not validate_time_ranges(hour, minute) then
    return nil
  end

  local hour_24 = convert_to_24_hour(hour, period)
  return hour_24 * 60 + minute
end

return time_utils