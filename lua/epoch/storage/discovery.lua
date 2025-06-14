-- epoch/storage/discovery.lua
-- Timesheet file discovery operations

local discovery = {}
local paths = require('epoch.storage.paths')
local constants = require('epoch.constants')

-- Validate data directory exists
local function validate_data_directory()
  local data_dir = paths.get_data_dir()
  if vim.fn.isdirectory(data_dir) == 0 then
    return nil
  end
  return data_dir
end

-- Discover all lua files in data directory
local function discover_lua_files(data_dir)
  local pattern = data_dir .. "/*.lua"
  return vim.fn.glob(pattern, false, true)
end

-- Filter files for timesheet pattern (YYYY-MM-DD.lua)
local function filter_timesheet_files(files)
  local timesheet_files = {}
  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":t")
    if filename:match(constants.TIMESHEET_FILENAME_PATTERN) then
      table.insert(timesheet_files, file)
    end
  end
  return timesheet_files
end

-- Get all timesheet files in the data directory
function discovery.get_all_timesheet_files()
  local data_dir = validate_data_directory()
  if not data_dir then return {} end

  local files = discover_lua_files(data_dir)
  return filter_timesheet_files(files)
end

return discovery