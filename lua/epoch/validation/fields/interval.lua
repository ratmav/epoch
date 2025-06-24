-- epoch/validation/fields/interval.lua
-- Individual interval validation

local time_utils = require('epoch.time')

local interval = {}

-- Validate required fields in interval
local function validate_required_fields(current_interval)
  if current_interval.client == nil or current_interval.client == "" then
    return false, "client cannot be empty"
  end
  if current_interval.project == nil or current_interval.project == "" then
    return false, "project cannot be empty"
  end
  if current_interval.task == nil or current_interval.task == "" then
    return false, "task cannot be empty"
  end
  return true
end

-- Validate time format fields in interval
local function validate_time_fields(current_interval)
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

-- Validate notes field in interval
local function validate_notes_field(current_interval)
  if current_interval.notes == nil then
    return false, "notes field is required (should be an empty array or array of strings)"
  end
  if type(current_interval.notes) ~= "table" then
    return false, "notes must be an array of strings"
  end
  for i, note in ipairs(current_interval.notes) do
    if type(note) ~= "string" then
      return false, string.format("note at position %d must be a string", i)
    end
  end
  return true
end

-- Validate interval structure and required fields
function interval.validate(current_interval)
  if type(current_interval) ~= "table" then
    return false, "interval must be a table"
  end

  local ok, err = validate_required_fields(current_interval)
  if not ok then return false, err end

  ok, err = validate_time_fields(current_interval)
  if not ok then return false, err end

  return validate_notes_field(current_interval)
end

return interval