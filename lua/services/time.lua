-- services/time.lua
-- Generic time parsing and formatting utilities

local time = {}

-- Parse time string components
local function parse_time_components(time_str)
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

-- Parse date components from YYYY-MM-DD format
local function parse_date_components(date_str)
  if not date_str then return nil end
  
  local year, month, day = date_str:match("^(%d+)-(%d+)-(%d+)$")
  if not year or not month or not day then
    return nil
  end
  return tonumber(year), tonumber(month), tonumber(day)
end

-- Check if time string is in valid 12-hour format
function time.is_valid_format(time_str)
  local hour, minute, period = parse_time_components(time_str)
  if not hour then return false end
  
  return validate_time_ranges(hour, minute)
end

-- Convert time string to minutes since midnight
function time.to_minutes_since_midnight(time_str)
  local hour, minute, period = parse_time_components(time_str)
  if not hour then return nil end

  if not validate_time_ranges(hour, minute) then
    return nil
  end

  local hour_24 = convert_to_24_hour(hour, period)
  return hour_24 * 60 + minute
end

-- Format timestamp as 12-hour time string
function time.format_current_time(timestamp)
  timestamp = timestamp or os.time()
  local time_table = os.date("*t", timestamp)
  
  local hour = time_table.hour
  local minute = time_table.min
  local period = "AM"
  
  if hour == 0 then
    hour = 12
  elseif hour >= 12 then
    period = "PM"
    if hour > 12 then
      hour = hour - 12
    end
  end
  
  return string.format("%d:%02d %s", hour, minute, period)
end

-- Format minutes as HH:MM duration string
function time.format_duration(minutes)
  if minutes < 0 then
    minutes = 0
  end
  
  local hours = math.floor(minutes / 60)
  local mins = minutes % 60
  
  return string.format("%02d:%02d", hours, mins)
end

-- Parse time string with optional date to timestamp
function time.parse_to_timestamp(time_str, date_str)
  local hour, minute, period = parse_time_components(time_str)
  if not hour then return nil end

  local year, month, day
  if date_str then
    year, month, day = parse_date_components(date_str)
    if not year then return nil end
  else
    local today = os.date("*t")
    year, month, day = today.year, today.month, today.day
  end

  local hour_24 = convert_to_24_hour(hour, period)
  return os.time({
    year = year,
    month = month,
    day = day,
    hour = hour_24,
    min = minute
  })
end

return time