-- epoch/ui/timesheet_controller.lua
-- Controls timesheet UI flow and user interactions

local timesheet_controller = {}
local storage = require('epoch.storage')
local timesheet_window = require('epoch.ui.timesheet_window')

-- Handle timesheet opening flow
function timesheet_controller.handle_open(ui, date)
  local path = storage.get_timesheet_path(date)

  if vim.fn.filereadable(path) == 0 then
    if date then
      -- For specific dates, create empty timesheet instead of prompting for interval
      timesheet_window.open(date)
    else
      -- For today, prompt for interval if no timesheet exists
      ui.add_interval_and_edit()
    end
  else
    timesheet_window.open(date)
  end
end

return timesheet_controller