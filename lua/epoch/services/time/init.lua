-- services/time/init.lua
-- Time service delegation

local time = {}
local conversion = require('epoch.services.time.conversion')
local formatting = require('epoch.services.time.formatting')

-- Delegate to conversion module
time.is_valid_format = conversion.is_valid_format
time.to_minutes_since_midnight = conversion.to_minutes_since_midnight

-- Delegate to formatting module
time.format_current_time = formatting.format_current_time
time.format_duration = formatting.format_duration
time.parse_to_timestamp = formatting.parse_to_timestamp

return time
