-- epoch/commands/register.lua
-- vim command registration

local ui = require('epoch.ui')
local storage = require('epoch.storage')
local confirmations = require('epoch.ui.confirmations')
local validation = require('epoch.commands.validation')

local register = {}

function register.create_edit_command()
  vim.api.nvim_create_user_command('EpochEdit', function(opts)
    local date = opts.args and opts.args ~= "" and opts.args or nil
    if date and not validation.validate_date_format(date) then
      vim.notify("epoch: invalid date format. Use YYYY-MM-DD (e.g., 2024-12-25)", vim.log.levels.ERROR)
      return
    end
    ui.toggle_timesheet(date)
  end, {
    nargs = '?',
    desc = 'Edit timesheet for today or specified date (YYYY-MM-DD)'
  })
end

function register.create_interval_command()
  vim.api.nvim_create_user_command('EpochInterval', function()
    ui.add_interval()
  end, {})
end

function register.create_report_command()
  vim.api.nvim_create_user_command('EpochReport', function()
    require('epoch.report').toggle_report()
  end, {})
end

function register.create_list_command()
  vim.api.nvim_create_user_command('EpochList', function()
    require('epoch.list').show_timesheet_list()
  end, {
    desc = 'Show all timesheets in quickfix list'
  })
end

function register.create_clear_command()
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

function register.register()
  register.create_edit_command()
  register.create_interval_command()
  register.create_report_command()
  register.create_list_command()
  register.create_clear_command()
end

return register