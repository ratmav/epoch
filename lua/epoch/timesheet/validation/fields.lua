-- epoch/timesheet/validation/fields.lua
-- Validate timesheet fields (date, intervals array structure)

local fields = {}

function fields.validate(current_timesheet)
  if type(current_timesheet) ~= "table" then
    return false, "timesheet must be a table"
  end

  if not current_timesheet.date then
    return false, "missing date field"
  end

  if type(current_timesheet.intervals) ~= "table" then
    return false, "intervals must be a table"
  end

  return true
end

return fields