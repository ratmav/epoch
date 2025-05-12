-- epoch/ui/logic/workflow.lua
-- Complete workflows combining multiple operations (pure logic)

local interval_ops = require('epoch.ui.interval')
local timesheet_logic = require('epoch.ui.logic.timesheet')
local timesheet_module = require('epoch.ui.timesheet')

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

-- Create timesheet window with configuration
function workflow_logic.create_timesheet_window(content, timesheet_path, window)
  return window.create({
    id = "timesheet",
    title = "epoch - timesheet",
    width_percent = 0.4,
    height_percent = 0.7,
    filetype = "lua",
    modifiable = true,
    buffer_name = timesheet_path,
    content = content,
    on_save = timesheet_module.validate_and_save_from_buffer
  })
end

-- Open timesheet window
function workflow_logic.open_timesheet(storage, window, date)
  local timesheet_path = storage.get_timesheet_path(date)
  timesheet_logic.ensure_timesheet_exists(timesheet_path, storage, date)
  local content = timesheet_logic.load_timesheet_content(timesheet_path)
  return workflow_logic.create_timesheet_window(content, timesheet_path, window)
end

-- Handle timesheet opening logic
function workflow_logic.handle_timesheet_open(storage, window, ui, date)
  local path = storage.get_timesheet_path(date)

  if vim.fn.filereadable(path) == 0 then
    if date then
      -- For specific dates, create empty timesheet instead of prompting for interval
      workflow_logic.open_timesheet(storage, window, date)
    else
      -- For today, prompt for interval if no timesheet exists
      ui.add_interval_and_edit()
    end
  else
    workflow_logic.open_timesheet(storage, window, date)
  end
end

return workflow_logic