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

-- Parse and validate time components from time string
local function parse_time_components(time_str)
  if not time_utils.is_valid_time_format(time_str) then
    return nil
  end
  
  local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
  if not hour or not min or not period then
    return nil
  end
  
  return tonumber(hour), tonumber(min), period
end

-- Convert 12-hour format to 24-hour format
local function convert_to_24_hour(hour, period)
  if period == "PM" and hour < 12 then
    return hour + 12
  elseif period == "AM" and hour == 12 then
    return 0
  end
  return hour
end

-- Parse date components from YYYY-MM-DD format
local function parse_date_components(date_str)
  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
  if not year or not month or not day then
    return nil
  end
  return tonumber(year), tonumber(month), tonumber(day)
end

-- Create timestamp from date and time components
local function create_timestamp(year, month, day, hour, min)
  return os.time({
    year = year,
    month = month,
    day = day,
    hour = hour,
    min = min
  })
end

-- convert time string to timestamp
function time_utils.time_to_seconds(time_str, date_str)
  local hour, min, period = parse_time_components(time_str)
  if not hour then return nil end
  
  local year, month, day = parse_date_components(date_str)
  if not year then return nil end
  
  local hour_24 = convert_to_24_hour(hour, period)
  return create_timestamp(year, month, day, hour_24, min)
end

-- format timestamp as h:MM AM/PM
function time_utils.format_time(timestamp)
  return os.date('%I:%M %p', timestamp)
end

-- parse a time string (HH:MM AM/PM) to a timestamp
-- uses today's date as the base
function time_utils.parse_time(time_str)
  local hour, min, period = parse_time_components(time_str)
  if not hour then return nil end
  
  local today = os.date("*t")
  local hour_24 = convert_to_24_hour(hour, period)
  
  return create_timestamp(today.year, today.month, today.day, hour_24, min)
end

return time_utils