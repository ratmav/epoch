-- epoch/ui/timesheet_window.lua
-- Timesheet window creation and management

local timesheet_window = {}
local storage = require('epoch.storage')
local window = require('epoch.ui.window')
local timesheet_workflow = require('epoch.workflow.timesheet')

-- Create and open timesheet window
function timesheet_window.open(date)
  local timesheet_path = storage.get_timesheet_path(date)
  timesheet_workflow.ensure_timesheet_exists(timesheet_path, date)
  local content = table.concat(vim.fn.readfile(timesheet_path), '\n')
  
  return window.create({
    id = "timesheet",
    title = "epoch - timesheet",
    width_percent = 0.4,
    height_percent = 0.7,
    filetype = "lua",
    modifiable = true,
    buffer_name = timesheet_path,
    content = content,
    on_save = require('epoch.ui.timesheet').validate_and_save_from_buffer
  })
end

return timesheet_window