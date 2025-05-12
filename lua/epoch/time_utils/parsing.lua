-- epoch/time_utils/parsing.lua
-- Time string parsing utilities

local validation = require('epoch.time_utils.validation')

local parsing = {}

-- Parse and validate time components from time string
local function parse_time_components(time_str)
  if not validation.is_valid_time_format(time_str) then
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
function parsing.time_to_seconds(time_str, date_str)
  local hour, min, period = parse_time_components(time_str)
  if not hour then return nil end

  local year, month, day = parse_date_components(date_str)
  if not year then return nil end

  local hour_24 = convert_to_24_hour(hour, period)
  return create_timestamp(year, month, day, hour_24, min)
end

-- parse a time string (HH:MM AM/PM) to a timestamp
-- uses today's date as the base
function parsing.parse_time(time_str)
  local hour, min, period = parse_time_components(time_str)
  if not hour then return nil end

  local today = os.date("*t")
  local hour_24 = convert_to_24_hour(hour, period)

  return create_timestamp(today.year, today.month, today.day, hour_24, min)
end

return parsing