-- epoch/time_utils.lua
-- utility functions for time operations

local validation = require('epoch.time_utils.validation')
local parsing = require('epoch.time_utils.parsing')
local formatting = require('epoch.time_utils.formatting')

local time_utils = {}

-- check if time string is formatted correctly (12-hour format)
function time_utils.is_valid_time_format(time_str)
  return validation.is_valid_time_format(time_str)
end

-- format minutes as HH:MM
function time_utils.format_duration(minutes)
  return formatting.format_duration(minutes)
end

-- convert time string to timestamp
function time_utils.time_to_seconds(time_str, date_str)
  return parsing.time_to_seconds(time_str, date_str)
end

-- format timestamp as h:MM AM/PM
function time_utils.format_time(timestamp)
  return formatting.format_time(timestamp)
end

-- parse a time string (HH:MM AM/PM) to a timestamp
-- uses today's date as the base
function time_utils.parse_time(time_str)
  return parsing.parse_time(time_str)
end

return time_utils