-- epoch/interval/validation/time_fields.lua
-- Validate time format fields in interval

local time_utils = require('epoch.time')

local time_fields = {}

function time_fields.validate(current_interval)
  if not current_interval.start then
    return false, "start time is missing"
  end
  if not time_utils.is_valid_time_format(current_interval.start) then
    return false, string.format("start time '%s' must be in format 'HH:MM AM/PM'", current_interval.start)
  end
  local stop_time = current_interval.stop
  if stop_time and stop_time ~= "" and not time_utils.is_valid_time_format(stop_time) then
    return false, string.format("stop time '%s' must be in format 'HH:MM AM/PM'", stop_time)
  end
  return true
end

return time_fields