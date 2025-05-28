-- epoch/validation/fields.lua
-- Field validation for intervals and timesheets

local fields = {}
local time_utils = require('epoch.time_utils')

-- Validate required fields in interval
local function validate_required_fields(interval)
  if interval.client == nil or interval.client == "" then
    return false, "client cannot be empty"
  end
  if interval.project == nil or interval.project == "" then
    return false, "project cannot be empty"
  end
  if interval.task == nil or interval.task == "" then
    return false, "task cannot be empty"
  end
  return true
end

-- Validate time format fields in interval
local function validate_time_fields(interval)
  if not interval.start then
    return false, "start time is missing"
  end
  if not time_utils.is_valid_time_format(interval.start) then
    return false, string.format("start time '%s' must be in format 'HH:MM AM/PM'", interval.start)
  end
  if interval.stop and interval.stop ~= "" and not time_utils.is_valid_time_format(interval.stop) then
    return false, string.format("stop time '%s' must be in format 'HH:MM AM/PM'", interval.stop)
  end
  return true
end

-- Validate notes field in interval
local function validate_notes_field(interval)
  if interval.notes == nil then
    return false, "notes field is required (should be an empty array or array of strings)"
  end
  if type(interval.notes) ~= "table" then
    return false, "notes must be an array of strings"
  end
  for i, note in ipairs(interval.notes) do
    if type(note) ~= "string" then
      return false, string.format("note at position %d must be a string", i)
    end
  end
  return true
end

-- Validate interval structure and required fields
function fields.validate_interval(interval)
  if type(interval) ~= "table" then
    return false, "interval must be a table"
  end
  
  local ok, err = validate_required_fields(interval)
  if not ok then return false, err end
  
  ok, err = validate_time_fields(interval)
  if not ok then return false, err end
  
  ok, err = validate_notes_field(interval)
  if not ok then return false, err end
  
  return true
end

-- Validate timesheet structure
function fields.validate_timesheet(timesheet)
  if type(timesheet) ~= "table" then
    return false, "timesheet must be a table"
  end

  -- Check for required fields
  if not timesheet.date then
    return false, "missing date field"
  end

  if type(timesheet.intervals) ~= "table" then
    return false, "intervals must be a table"
  end

  -- Validate each interval
  for i, interval in ipairs(timesheet.intervals) do
    local valid, err = fields.validate_interval(interval)
    if not valid then
      local context = fields.get_interval_context(interval)
      local context_str = ""
      if context and context ~= "unknown interval" then
        context_str = " (" .. context .. ")"
      end
      return false, "invalid interval at index " .. i .. context_str .. ": " .. err
    end
  end

  return true
end

-- Get human-readable context for an interval
function fields.get_interval_context(interval)
  if not interval then
    return "unknown interval"
  end
  
  local parts = {}
  
  if interval.client then
    table.insert(parts, interval.client)
  end
  
  if interval.project then
    table.insert(parts, interval.project)
  end
  
  if interval.task then
    table.insert(parts, interval.task)
  end
  
  if interval.start then
    table.insert(parts, interval.start)
  end
  
  if #parts == 0 then
    return "unknown interval"
  end
  
  return table.concat(parts, "/")
end

return fields