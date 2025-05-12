-- epoch/ui/init.lua
-- UI functionality for epoch time tracking
-- coverage: no tests

local ui = {}
local storage = require('epoch.storage')
local window = require('epoch.ui.window')
local input = require('epoch.ui.input')
local logic = require('epoch.ui.logic')

-- Set up the UI module
function ui.setup()
  window.setup()
end

-- Toggle timesheet window
function ui.toggle_timesheet(date)
  if window.is_open("timesheet") then
    window.close("timesheet")
  else
    logic.handle_timesheet_open(storage, window, ui, date)
  end
end

-- Add a new interval and then open the timesheet window
function ui.add_interval_and_edit()
  ui.add_interval(function()
    logic.open_timesheet(storage, window)
  end)
end

-- Add a new interval
function ui.add_interval(callback)
  input.prompt_for_interval(callback)
end

return ui