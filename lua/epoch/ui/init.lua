-- epoch/ui/init.lua
-- UI functionality for epoch time tracking
-- coverage: no tests

local ui = {}
local window = require('epoch.ui.window')
local input = require('epoch.ui.input')
local timesheet_window = require('epoch.ui.timesheet_window')
local timesheet_controller = require('epoch.ui.timesheet_controller')
local report_controller = require('epoch.ui.report_controller')

-- Set up the UI module
function ui.setup()
  window.setup()
end

-- Toggle timesheet window
function ui.toggle_timesheet(date)
  if window.is_open("timesheet") then
    window.close("timesheet")
  else
    timesheet_controller.handle_open(ui, date)
  end
end

-- Add a new interval and then open the timesheet window
function ui.add_interval_and_edit()
  ui.add_interval(function()
    timesheet_window.open()
  end)
end

-- Add a new interval
function ui.add_interval(callback)
  input.prompt_for_interval(callback)
end

-- Toggle report window
function ui.toggle_report()
  report_controller.handle_toggle()
end

return ui