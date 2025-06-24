-- epoch/validation.lua
-- Main validation interface - delegates to specialized modules
-- coverage: no tests

local validation = {}
local interval_validator = require('epoch.validation.fields.interval')
local timesheet_validation = require('epoch.validation.timesheet')
local context = require('epoch.validation.fields.context')
local overlap = require('epoch.validation.overlap')
local time_utils = require('epoch.validation.time_utils')

-- Public API: Validate interval structure and fields
function validation.validate_interval(interval)
  return interval_validator.validate(interval)
end

-- Public API: Validate timesheet structure
function validation.validate_timesheet(timesheet)
  return timesheet_validation.validate(timesheet)
end

-- Public API: Get human-readable context for an interval
function validation.get_interval_context(interval)
  return context.get_interval_context(interval)
end

-- Public API: Convert time string to minutes since midnight
function validation.time_value(time_str)
  return time_utils.time_value(time_str)
end

-- Public API: Check for overlapping intervals
function validation.check_overlapping_intervals(intervals)
  return overlap.check_overlapping_intervals(intervals)
end

return validation