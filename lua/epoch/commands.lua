-- epoch/commands.lua
-- command handling module for epoch time tracking

local commands = {}
local ui = require('epoch.ui')
local storage = require('epoch.storage')
local confirmations = require('epoch.ui.confirmations')

-- Register edit command
local function register_edit_command()
  vim.api.nvim_create_user_command('EpochEdit', function()
    ui.toggle_timesheet()
  end, {})
end

-- Register interval command  
local function register_interval_command()
  vim.api.nvim_create_user_command('EpochInterval', function()
    ui.add_interval()
  end, {})
end

-- Register report command
local function register_report_command()
  vim.api.nvim_create_user_command('EpochReport', function()
    require('epoch.report').toggle_report()
  end, {})
end

-- Register clear command
local function register_clear_command()
  vim.api.nvim_create_user_command('EpochClear', function()
    confirmations.confirm_action(
      "Are you sure you want to delete ALL timesheet files? (y/N): ",
      function()
        local count = storage.delete_all_timesheets()
        vim.notify(string.format("epoch: deleted %d timesheet files", count), vim.log.levels.INFO)
      end
    )
  end, {})
end

-- Register all commands
function commands.register()
  register_edit_command()
  register_interval_command()
  register_report_command()
  register_clear_command()
end

return commands