-- epoch/time/init.lua
-- Time utilities interface - delegates to specialized modules
-- coverage: no tests

local time = {}
local validation = require('epoch.time.validation')
local parsing = require('epoch.time.parsing')
local formatting = require('epoch.time.formatting')

-- Public API: check if time string is formatted correctly (12-hour format)
function time.is_valid_time_format(time_str)
  return validation.is_valid_time_format(time_str)
end

-- Public API: format minutes as HH:MM
function time.format_duration(minutes)
  return formatting.format_duration(minutes)
end

-- Public API: convert time string to timestamp
function time.time_to_seconds(time_str, date_str)
  return parsing.time_to_seconds(time_str, date_str)
end

-- Public API: format timestamp as h:MM AM/PM
function time.format_time(timestamp)
  return formatting.format_time(timestamp)
end

-- Public API: parse a time string (HH:MM AM/PM) to a timestamp
function time.parse_time(time_str)
  return parsing.parse_time(time_str)
end

-- Public API: convert time string to minutes since midnight for comparison
function time.time_value(time_str)
  return parsing.time_value(time_str)
end

return time