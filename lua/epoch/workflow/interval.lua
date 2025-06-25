-- epoch/workflow/interval.lua
-- Interval workflow orchestration

local interval_workflow = {}
local interval_creation = require('epoch.interval.creation')
local interval_calculation = require('epoch.interval.calculation')
local interval_timing = require('epoch.interval.timing')
local timesheet_calculation = require('epoch.timesheet.calculation')

-- Validate required input fields
local function validate_inputs(client, project, task)
  if not client or client == "" then
    return false, "client is required"
  end
  if not project or project == "" then
    return false, "project is required"
  end
  if not task or task == "" then
    return false, "task is required"
  end
  return true, nil
end

-- Handle timing and create new interval
local function create_and_add_interval(client, project, task, timesheet)
  local current_time = os.time()
  local updated_timesheet = vim.deepcopy(timesheet)

  local adjusted_start, previous_stop = interval_timing.resolve_timing(updated_timesheet, current_time)

  if previous_stop then
    interval_creation.close_current(updated_timesheet, previous_stop)
  end

  local new_interval = interval_creation.create(client, project, task, adjusted_start)
  table.insert(updated_timesheet.intervals, new_interval)

  return timesheet_calculation.update_daily_total(updated_timesheet, interval_calculation.calculate_daily_total)
end

-- Complete workflow for adding an interval with all business logic
function interval_workflow.add_interval(client, project, task, timesheet)
  local valid, error_msg = validate_inputs(client, project, task)
  if not valid then
    return false, error_msg, nil
  end

  local updated_timesheet = create_and_add_interval(client, project, task, timesheet)
  return true, nil, updated_timesheet
end

return interval_workflow