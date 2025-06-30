-- epoch/storage/paths.lua
-- Path and directory management for timesheet storage

local paths = {}

-- Data directory path (configurable for testing)
local data_dir = nil

-- Set custom data directory (mainly for testing)
function paths.set_data_dir(path)
  data_dir = path
end

-- Get the data directory path
function paths.get_data_dir()
  if data_dir then
    return data_dir
  end

  local nvim_data = vim.fn.stdpath('data')
  return nvim_data .. '/epoch'
end

-- Get today's date in YYYY-MM-DD format
function paths.get_today()
  return os.date("%Y-%m-%d")
end

-- Get the path for a timesheet file
function paths.get_timesheet_path(date)
  date = date or paths.get_today()
  return paths.get_data_dir() .. "/" .. date .. ".lua"
end

-- Ensure the data directory exists
function paths.ensure_data_dir()
  local dir = paths.get_data_dir()
  vim.fn.mkdir(dir, "p")
end

-- Extract date from timesheet filename
function paths.extract_date_from_filename(filepath)
  local constants = require('epoch.constants')
  local basename = vim.fn.fnamemodify(filepath, ":t:r")
  return basename:match(constants.TIMESHEET_DATE_PATTERN_WITH_CAPTURE)
end

return paths