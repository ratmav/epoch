-- epoch/ui/logic/workflow.lua
-- Complete workflows combining multiple operations (pure logic)

local interval_ops = require('epoch.ui.interval')
local timesheet_logic = require('epoch.ui.logic.timesheet')

local workflow_logic = {}

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

  local adjusted_start, previous_stop = interval_ops.resolve_timing(updated_timesheet, current_time)

  if previous_stop then
    interval_ops.close_current(updated_timesheet, previous_stop)
  end

  local new_interval = interval_ops.create(client, project, task, adjusted_start)
  table.insert(updated_timesheet.intervals, new_interval)

  return timesheet_logic.update_daily_total(updated_timesheet, interval_ops.calculate_daily_total)
end

-- Complete workflow for adding an interval with all business logic
function workflow_logic.add_interval(client, project, task, timesheet)
  local valid, error_msg = validate_inputs(client, project, task)
  if not valid then
    return false, error_msg, nil
  end

  local updated_timesheet = create_and_add_interval(client, project, task, timesheet)
  return true, nil, updated_timesheet
end

return workflow_logic