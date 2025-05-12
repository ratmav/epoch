-- epoch/init.lua
-- a lightweight time tracking plugin for neovim

local epoch = {}

local ui = require('epoch.ui')
local timeops = require('epoch.timeops')
local config = require('epoch.config')
local commands = require('epoch.commands')

-- setup function to initialize plugin
function epoch.setup(opts)
  -- initialize configuration
  config.setup(opts)
  
  -- register commands
  commands.register()
  
  -- setup ui components
  ui.setup()
end

-- edit/toggle timesheet window
function epoch.edit()
  ui.toggle_timesheet()
end

-- add time interval
function epoch.add_interval()
  timeops.add_interval()
end

-- toggle weekly report
function epoch.show_report()
  ui.toggle_report()
end

-- clear all timesheets
function epoch.clear_timesheets()
  timeops.clear_timesheets()
end

return epoch