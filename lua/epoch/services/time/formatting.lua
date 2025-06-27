-- services/time/formatting.lua
-- Time formatting utilities

local formatting = {}
local conversion = require('epoch.services.time.conversion')
local parsing = require('epoch.services.time.parsing')

-- Format timestamp as 12-hour time string
function formatting.format_current_time(timestamp)
  timestamp = timestamp or os.time()
  local time_table = os.date("*t", timestamp)

  local hour_12, period = conversion.convert_to_12_hour(time_table.hour)

  return string.format("%d:%02d %s", hour_12, time_table.min, period)
end

-- Format minutes as HH:MM duration string
function formatting.format_duration(minutes)
  if minutes < 0 then
    minutes = 0
  end

  local hours = math.floor(minutes / 60)
  local mins = minutes % 60

  return string.format("%02d:%02d", hours, mins)
end

-- Private: get date components (year, month, day)
local function get_date_components(date_str)
  if date_str then
    local year, month, day = parsing.parse_date_components(date_str)
    if not year then return nil end
    return year, month, day
  else
    local today = os.date("*t")
    return today.year, today.month, today.day
  end
end

-- Private: create timestamp from components
local function create_timestamp(year, month, day, hour_24, minute)
  return os.time({
    year = year,
    month = month,
    day = day,
    hour = hour_24,
    min = minute
  })
end

-- Parse time string with optional date to timestamp
function formatting.parse_to_timestamp(time_str, date_str)
  local hour, minute, period = parsing.parse_time_components(time_str)
  if not hour then return nil end

  local year, month, day = get_date_components(date_str)
  if not year then return nil end

  local hour_24 = conversion.convert_to_24_hour(hour, period)
  return create_timestamp(year, month, day, hour_24, minute)
end

return formatting
