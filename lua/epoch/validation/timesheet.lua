-- epoch/validation/timesheet.lua
-- Main timesheet validation logic

local timesheet_validation = {}
local timesheet_validator = require('epoch.validation.fields.timesheet')
local overlap = require('epoch.validation.overlap')

-- Helper: validate overlap rules for intervals
local function validate_overlap_rules(intervals)
  local has_multiple_open, multiple_open_err = overlap.check_multiple_open_intervals(intervals)
  if has_multiple_open then
    return false, multiple_open_err
  end

  local has_overlap, overlap_err = overlap.check_overlapping_intervals(intervals)
  if has_overlap then
    return false, overlap_err
  end

  return true
end

-- Validate complete timesheet structure and rules
function timesheet_validation.validate(timesheet)
  local valid, err = timesheet_validator.validate(timesheet)
  if not valid then
    return false, err
  end

  return validate_overlap_rules(timesheet.intervals)
end

return timesheet_validation