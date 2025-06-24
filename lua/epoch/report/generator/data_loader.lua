-- epoch/report/generator/data_loader.lua
-- Timesheet data loading and date extraction

local storage = require('epoch.storage')
local paths = require('epoch.storage.paths')

local data_loader = {}

local function extract_dates_from_files(files)
  local dates = {}
  for _, file_path in ipairs(files) do
    local date = paths.extract_date_from_filename(file_path)
    if date then
      table.insert(dates, date)
    end
  end
  return dates
end

local function sort_dates_chronologically(dates)
  table.sort(dates)
  return dates
end

-- Load all available timesheet dates
function data_loader.get_all_timesheet_dates()
  local files = storage.get_all_timesheet_files()
  local dates = extract_dates_from_files(files)
  return sort_dates_chronologically(dates)
end

-- Load all timesheets for given dates
function data_loader.load_timesheets(dates)
  local timesheets = {}

  for _, date in ipairs(dates) do
    local timesheet = storage.load_timesheet(date)
    if timesheet and timesheet.intervals and #timesheet.intervals > 0 then
      table.insert(timesheets, timesheet)
    end
  end

  return timesheets
end

return data_loader