-- models/interval/validation.lua
-- Interval validation operations

local validation = {}
local creation = require('models.interval.creation')

-- Private: validate required string field
local function validate_required_string(value, field_name)
  if not value or value == "" then
    return false, "Interval must have a " .. field_name
  end
  return true
end

-- Private: validate notes field
local function validate_notes(notes)
  if not notes then
    return false, "Interval must have notes field"
  end

  if type(notes) ~= "table" then
    return false, "Interval notes must be an array"
  end

  return true
end

-- Private: validate all required fields
local function validate_required_fields(this_interval)
  local fields = {
    {this_interval.client, "client"},
    {this_interval.project, "project"},
    {this_interval.task, "task"}
  }

  for _, field in ipairs(fields) do
    local is_valid, error_msg = validate_required_string(field[1], field[2])
    if not is_valid then return false, error_msg end
  end

  if not this_interval.start then
    return false, "Interval must have a start time"
  end

  return true
end

-- Check if interval has all required fields and is closed
function validation.is_complete(this_interval)
  if not this_interval.client or
     not this_interval.project or
     not this_interval.task or
     not this_interval.start then
    return false
  end

  return not creation.is_open(this_interval)
end

-- Validate interval structure and content
function validation.validate(this_interval)
  if not this_interval then
    return false, "Interval cannot be nil"
  end

  local is_valid, error_msg = validate_required_fields(this_interval)
  if not is_valid then return false, error_msg end

  return validate_notes(this_interval.notes)
end

return validation
