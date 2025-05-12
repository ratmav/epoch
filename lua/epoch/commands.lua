-- epoch/commands.lua
-- command handling module for epoch time tracking

local commands = {}
local ui = require('epoch.ui')
local timeops = require('epoch.timeops')

-- register all commands
function commands.register()
  -- edit/toggle today's timesheet window
  vim.api.nvim_create_user_command('EpochEdit', function()
    ui.toggle_timesheet()
  end, {})

  -- add new time interval
  vim.api.nvim_create_user_command('EpochInterval', function()
    timeops.add_interval()
  end, {})

  -- toggle weekly time report
  vim.api.nvim_create_user_command('EpochReport', function()
    ui.toggle_report()
  end, {})

  -- clear all timesheets
  vim.api.nvim_create_user_command('EpochClear', function()
    timeops.clear_timesheets()
  end, {})
end

return commands