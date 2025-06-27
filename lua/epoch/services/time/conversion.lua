-- services/time/conversion.lua
-- Time conversion utilities

local conversion = {}
local parsing = require('epoch.services.time.parsing')

-- Convert 12-hour to 24-hour format
function conversion.convert_to_24_hour(hour, period)
  if period == "AM" then
    return hour == 12 and 0 or hour
  else -- PM
    return hour == 12 and 12 or hour + 12
  end
end

-- Private: convert 24-hour to 12-hour format
function conversion.convert_to_12_hour(hour)
  if hour == 0 then
    return 12, "AM"
  elseif hour >= 12 then
    local period = "PM"
    local hour_12 = hour > 12 and hour - 12 or hour
    return hour_12, period
  else
    return hour, "AM"
  end
end

-- Check if time string is in valid 12-hour format
function conversion.is_valid_format(time_str)
  local hour, minute = parsing.parse_time_components(time_str)
  if not hour then return false end

  return parsing.validate_time_ranges(hour, minute)
end

-- Convert time string to minutes since midnight
function conversion.to_minutes_since_midnight(time_str)
  local hour, minute, period = parsing.parse_time_components(time_str)
  if not hour then return nil end

  if not parsing.validate_time_ranges(hour, minute) then
    return nil
  end

  local hour_24 = conversion.convert_to_24_hour(hour, period)
  return hour_24 * 60 + minute
end

return conversion
