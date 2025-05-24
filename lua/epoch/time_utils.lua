-- epoch/time_utils.lua
-- utility functions for time operations

local time_utils = {}

-- check if time string is formatted correctly (12-hour format)
function time_utils.is_valid_time_format(time_str)
  if not time_str or time_str == "" then
    return false
  end

  -- match pattern for "hh:mm AM/PM"
  if not time_str:match("^%d%d?:%d%d [AP]M$") then
    return false
  end
  
  -- additional validation for hour and minute values
  local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
  hour = tonumber(hour)
  min = tonumber(min)
  
  -- validate ranges
  if hour < 1 or hour > 12 or min < 0 or min > 59 then
    return false
  end
  
  return true
end

-- format minutes as HH:MM
function time_utils.format_duration(minutes)
  if not minutes or minutes < 0 then
    minutes = 0
  end
  
  local hours = math.floor(minutes / 60)
  local mins = math.floor(minutes % 60)
  return string.format("%02d:%02d", hours, mins)
end

-- convert time string to timestamp
function time_utils.time_to_seconds(time_str, date_str)
  -- validate inputs
  if not time_utils.is_valid_time_format(time_str) then
    return nil
  end
  
  -- parse time components
  local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
  if not hour or not min or not period then
    return nil
  end

  -- convert to 24 hour format
  hour = tonumber(hour)
  min = tonumber(min)

  if period == "PM" and hour < 12 then
    hour = hour + 12
  elseif period == "AM" and hour == 12 then
    hour = 0
  end

  -- get date components
  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
  if not year or not month or not day then
    return nil
  end

  -- create timestamp
  return os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = hour,
    min = min
  })
end

-- format timestamp as h:MM AM/PM
function time_utils.format_time(timestamp)
  return os.date('%I:%M %p', timestamp)
end

-- parse a time string (HH:MM AM/PM) to a timestamp
-- uses today's date as the base
function time_utils.parse_time(time_str)
  if not time_utils.is_valid_time_format(time_str) then
    return nil
  end
  
  -- parse time components
  local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
  if not hour or not min or not period then
    return nil
  end

  -- convert to 24 hour format
  hour = tonumber(hour)
  min = tonumber(min)

  if period == "PM" and hour < 12 then
    hour = hour + 12
  elseif period == "AM" and hour == 12 then
    hour = 0
  end

  -- get today's date components
  local today = os.date("*t")

  -- create timestamp
  return os.time({
    year = today.year,
    month = today.month,
    day = today.day,
    hour = hour,
    min = min
  })
end

return time_utils