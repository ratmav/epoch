-- models/timesheet/validation.lua
-- Timesheet validation operations

local validation = {}
local interval_model = require('epoch.models.interval')

-- Private: validate timesheet structure
local function validate_structure(this_timesheet)
  if not this_timesheet then
    return false, "Timesheet cannot be nil"
  end

  if not this_timesheet.date then
    return false, "Timesheet must have a date"
  end

  if not this_timesheet.intervals then
    return false, "Timesheet must have intervals array"
  end

  if type(this_timesheet.intervals) ~= "table" then
    return false, "Intervals must be a table"
  end

  return true
end

-- Private: validate all intervals
local function validate_intervals(this_timesheet)
  for i, interval in ipairs(this_timesheet.intervals) do
    local is_valid, error_msg = interval_model.validate(interval)
    if not is_valid then
      return false, string.format("Interval %d: %s", i, error_msg)
    end
  end
  return true
end

-- Validate timesheet structure and content
function validation.validate(this_timesheet)
  local is_valid, error_msg = validate_structure(this_timesheet)
  if not is_valid then
    return false, error_msg
  end

  return validate_intervals(this_timesheet)
end

return validation
