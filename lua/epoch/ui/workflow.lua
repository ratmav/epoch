-- epoch/ui/workflow.lua
-- Complete workflows combining multiple operations

local interval_ops = require('epoch.ui.interval')
local timesheet_ops = require('epoch.ui.timesheet')

local workflow = {}

-- Complete workflow for adding an interval with all business logic
-- Returns: success, error_message, updated_timesheet
function workflow.add_interval(client, project, task, timesheet)
  if not client or client == "" then
    return false, "client is required", nil
  end
  if not project or project == "" then
    return false, "project is required", nil
  end
  if not task or task == "" then
    return false, "task is required", nil
  end
  
  local current_time = os.time()
  local updated_timesheet = vim.deepcopy(timesheet)
  
  -- Handle timing conflicts and close previous interval if needed
  local adjusted_start, previous_stop = interval_ops.resolve_timing(updated_timesheet, current_time)
  
  -- Close previous interval if needed
  if previous_stop then
    interval_ops.close_current(updated_timesheet, previous_stop)
  end
  
  -- Create new interval
  local new_interval = interval_ops.create(client, project, task, adjusted_start)
  table.insert(updated_timesheet.intervals, new_interval)
  
  -- Update daily total
  updated_timesheet = timesheet_ops.update_daily_total(updated_timesheet, interval_ops.calculate_daily_total)
  
  return true, nil, updated_timesheet
end

return workflow