-- epoch/validation.lua
-- Main validation interface - delegates to specialized modules

local validation = {}
local fields = require('epoch.validation.fields')
local overlap = require('epoch.validation.overlap')
local time_utils = require('epoch.validation.time_utils')

-- Public API: Validate interval structure and fields
function validation.validate_interval(interval)
  return fields.validate_interval(interval)
end

-- Public API: Validate timesheet structure
function validation.validate_timesheet(timesheet)
  -- First validate structure and fields
  local valid, err = fields.validate_timesheet(timesheet)
  if not valid then
    return false, err
  end
  
  -- Then check for overlapping intervals
  local has_overlap, overlap_err = overlap.check_overlapping_intervals(timesheet.intervals, timesheet.date)
  if has_overlap then
    return false, overlap_err
  end
  
  return true
end

-- Public API: Get human-readable context for an interval
function validation.get_interval_context(interval)
  return fields.get_interval_context(interval)
end

-- Public API: Convert time string to minutes since midnight
function validation.time_value(time_str)
  return time_utils.time_value(time_str)
end

-- Public API: Check for overlapping intervals
function validation.check_overlapping_intervals(intervals, date)
  return overlap.check_overlapping_intervals(intervals, date)
end

return validation