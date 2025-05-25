-- epoch/validation/time_utils.lua
-- Time value parsing utilities for validation

local time_utils = {}

-- Convert time string to minutes since midnight for comparison
function time_utils.time_value(time_str)
  if not time_str or time_str == "" then
    return nil
  end
  
  -- Parse 12-hour format: "HH:MM AM/PM"
  local hour, minute, period = time_str:match("^(%d+):(%d+)%s*([AP]M)$")
  
  if not hour or not minute or not period then
    return nil
  end
  
  hour = tonumber(hour)
  minute = tonumber(minute)
  
  -- Validate ranges
  if hour < 1 or hour > 12 or minute < 0 or minute > 59 then
    return nil
  end
  
  -- Convert to 24-hour format
  if period == "AM" then
    if hour == 12 then
      hour = 0  -- 12 AM is midnight (0:xx)
    end
  else -- PM
    if hour ~= 12 then
      hour = hour + 12  -- 1 PM = 13:xx, 2 PM = 14:xx, etc.
    end
    -- 12 PM stays as 12:xx
  end
  
  -- Return minutes since midnight
  return hour * 60 + minute
end

return time_utils