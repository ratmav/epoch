-- epoch/validation/fields/timesheet.lua
-- Timesheet validation

local interval_validator = require('epoch.validation.fields.interval')
local context = require('epoch.validation.fields.context')

local timesheet = {}

-- Validate timesheet is a table
local function validate_timesheet_type(current_timesheet)
  if type(current_timesheet) ~= "table" then
    return false, "timesheet must be a table"
  end
  return true
end

-- Validate required timesheet fields
local function validate_timesheet_fields(current_timesheet)
  if not current_timesheet.date then
    return false, "missing date field"
  end

  if type(current_timesheet.intervals) ~= "table" then
    return false, "intervals must be a table"
  end

  return true
end

-- Validate all intervals in timesheet with context
local function validate_all_intervals(current_timesheet)
  for i, interval in ipairs(current_timesheet.intervals) do
    local valid, err = interval_validator.validate(interval)
    if not valid then
      local interval_context = context.get_interval_context(interval)
      local context_str = ""
      if interval_context and interval_context ~= "unknown interval" then
        context_str = " (" .. interval_context .. ")"
      end
      return false, "invalid interval at index " .. i .. context_str .. ": " .. err
    end
  end
  return true
end

-- Validate timesheet structure
function timesheet.validate(current_timesheet)
  local ok, err = validate_timesheet_type(current_timesheet)
  if not ok then return false, err end

  ok, err = validate_timesheet_fields(current_timesheet)
  if not ok then return false, err end

  return validate_all_intervals(current_timesheet)
end

return timesheet