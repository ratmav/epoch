-- epoch/timesheet/validation/intervals.lua
-- Validate all intervals within timesheet are valid

local interval_validation = require('epoch.interval.validation')

local intervals = {}

function intervals.validate(current_timesheet)
  if not current_timesheet.intervals then
    return true -- already validated by fields module
  end

  for i, interval in ipairs(current_timesheet.intervals) do
    local valid, err = interval_validation.required_fields.validate(interval)
    if not valid then
      return false, "invalid interval at index " .. i .. ": " .. err
    end

    valid, err = interval_validation.time_fields.validate(interval)
    if not valid then
      return false, "invalid interval at index " .. i .. ": " .. err
    end

    valid, err = interval_validation.notes_field.validate(interval)
    if not valid then
      return false, "invalid interval at index " .. i .. ": " .. err
    end
  end

  return true
end

return intervals