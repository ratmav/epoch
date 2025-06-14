-- epoch/commands.lua
-- command handling module for epoch time tracking
-- coverage: no tests

local commands = {}
local ui = require('epoch.ui')
local storage = require('epoch.storage')
local confirmations = require('epoch.ui.confirmations')
local date_calculation = require('epoch.report.week_utils.date_calculation')

-- Register edit command
local function register_edit_command()
  vim.api.nvim_create_user_command('EpochEdit', function(opts)
    local date = opts.args and opts.args ~= "" and opts.args or nil

    -- Validate date if provided - get_week_number returns nil for invalid dates
    if date and not date_calculation.get_week_number(date) then
      vim.notify("epoch: invalid date format. Use YYYY-MM-DD (e.g., 2024-12-25)", vim.log.levels.ERROR)
      return
    end

    ui.toggle_timesheet(date)
  end, {
    nargs = '?',
    desc = 'Edit timesheet for today or specified date (YYYY-MM-DD)'
  })
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

-- Register list command
local function register_list_command()
  vim.api.nvim_create_user_command('EpochList', function()
    require('epoch.list').show_timesheet_list()
  end, {
    desc = 'Show all timesheets in quickfix list'
  })
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
  register_list_command()
  register_clear_command()
end

return commands
