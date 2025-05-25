-- epoch/commands.lua
-- command handling module for epoch time tracking

local commands = {}
local ui = require('epoch.ui')
local storage = require('epoch.storage')

-- register all commands
function commands.register()
  -- edit/toggle today's timesheet window
  vim.api.nvim_create_user_command('EpochEdit', function()
    ui.toggle_timesheet()
  end, {})

  -- add new time interval
  vim.api.nvim_create_user_command('EpochInterval', function()
    ui.add_interval()
  end, {})

  -- toggle weekly time report
  vim.api.nvim_create_user_command('EpochReport', function()
    require('epoch.report').toggle_report()
  end, {})

  -- clear all timesheets with confirmation
  vim.api.nvim_create_user_command('EpochClear', function()
    -- Ask for confirmation
    vim.ui.input({
      prompt = "Are you sure you want to delete ALL timesheet files? (y/N): "
    }, function(input)
      -- Clear the command line
      vim.cmd("redraw!")

      -- Only proceed if the user explicitly confirms with 'y' or 'Y'
      if input and (input == "y" or input == "Y") then
        local count = storage.delete_all_timesheets()
        vim.notify(string.format("epoch: deleted %d timesheet files", count), vim.log.levels.INFO)
      else
        vim.notify("epoch: operation cancelled", vim.log.levels.INFO)
      end
    end)
  end, {})
end

return commands