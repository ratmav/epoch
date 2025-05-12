-- epoch/list.lua
-- Timesheet listing functionality
-- coverage: no tests

local list = {}
local storage = require('epoch.storage')
local paths = require('epoch.storage.paths')

-- Extract dates from timesheet files
local function get_timesheet_dates(timesheet_files)
  local dates = {}

  for _, filepath in ipairs(timesheet_files) do
    local date = paths.extract_date_from_filename(filepath)
    if date then
      table.insert(dates, date)
    end
  end

  -- Sort chronologically (YYYY-MM-DD format sorts naturally)
  table.sort(dates)
  return dates
end

-- Print timesheet list to user
function list.show_timesheet_list()
  local timesheet_files = storage.get_all_timesheet_files()

  if #timesheet_files == 0 then
    vim.notify("epoch: no timesheet files found", vim.log.levels.INFO)
    return
  end

  local dates = get_timesheet_dates(timesheet_files)

  vim.notify("epoch: available timesheets", vim.log.levels.INFO)
  for _, date in ipairs(dates) do
    print(date)
  end
end

return list
