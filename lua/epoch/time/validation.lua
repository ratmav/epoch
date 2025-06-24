-- epoch/time_utils/validation.lua
-- Time string validation utilities

local validation = {}

-- Validate time string format
local function validate_time_pattern(time_str)
  if not time_str or time_str == "" then
    return false
  end
  return time_str:match("^%d%d?:%d%d [AP]M$") ~= nil
end

-- Validate time component ranges
local function validate_time_components(time_str)
  local hour, min = time_str:match("(%d+):(%d+)%s+[AP]M")
  hour = tonumber(hour)
  min = tonumber(min)

  return hour >= 1 and hour <= 12 and min >= 0 and min <= 59
end

-- check if time string is formatted correctly (12-hour format)
function validation.is_valid_time_format(time_str)
  if not validate_time_pattern(time_str) then
    return false
  end

  return validate_time_components(time_str)
end

return validation