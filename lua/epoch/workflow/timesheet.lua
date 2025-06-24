-- epoch/workflow/timesheet.lua
-- Timesheet workflow orchestration

local storage = require('epoch.storage')
local timesheet_validation = require('epoch.timesheet.validation')
local timesheet_calculation = require('epoch.timesheet.calculation')
local interval_creation = require('epoch.interval.creation')

local timesheet_workflow = {}

-- Validate timesheet structure and business rules
local function validate_timesheet_structure(timesheet_data)
  local valid, err = timesheet_validation.fields.validate(timesheet_data)
  if not valid then return nil, err end

  valid, err = timesheet_validation.intervals.validate(timesheet_data)
  if not valid then return nil, err end

  valid, err = timesheet_validation.overlap.validate(timesheet_data)
  if not valid then return nil, err end

  valid, err = timesheet_validation.open_intervals.validate(timesheet_data)
  if not valid then return nil, err end

  return timesheet_data, nil
end

-- Process validated timesheet data
local function process_validated_timesheet(timesheet_data)
  return timesheet_calculation.recalculate_interval_hours(timesheet_data)
end

-- Ensure timesheet file exists, create if needed
function timesheet_workflow.ensure_timesheet_exists(timesheet_path, date)
  if vim.fn.filereadable(timesheet_path) == 0 then
    local timesheet_data = storage.create_default_timesheet(date)
    storage.save_timesheet(timesheet_data)
  end
end

-- Complete workflow: parse content, validate, and recalculate hours
function timesheet_workflow.validate_content(content)
  local timesheet_data, parse_err = storage.deserialize_content(content)
  if not timesheet_data then
    return nil, parse_err
  end

  local valid_data, validation_err = validate_timesheet_structure(timesheet_data)
  if not valid_data then
    return nil, validation_err
  end

  return process_validated_timesheet(valid_data), nil
end

-- Add a new interval to timesheet (workflow operation)
-- If there's an unclosed interval, it will be closed first
function timesheet_workflow.add_to_timesheet(timesheet, new_interval)
  local updated = vim.deepcopy(timesheet)
  interval_creation.close_current(updated)
  table.insert(updated.intervals, new_interval)
  return updated
end

return timesheet_workflow