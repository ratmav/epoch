-- epoch/storage/file_ops.lua
-- File operations for timesheet storage

local file_ops = {}
local paths = require('epoch.storage.paths')
local serializer = require('epoch.storage.serializer')

-- Save a timesheet to disk
function file_ops.save_timesheet(timesheet)
  if not timesheet or not timesheet.date then
    return false, "invalid timesheet data"
  end
  
  paths.ensure_data_dir()
  local file_path = paths.get_timesheet_path(timesheet.date)
  local content = serializer.serialize_timesheet(timesheet)
  
  local success, err = pcall(function()
    local file = io.open(file_path, 'w')
    if not file then
      error("could not open file for writing: " .. file_path)
    end
    file:write(content)
    file:close()
  end)
  
  return success, err
end

-- Load a timesheet from disk
function file_ops.load_timesheet(date)
  date = date or paths.get_today()
  local file_path = paths.get_timesheet_path(date)
  
  -- Check if file exists
  if vim.fn.filereadable(file_path) == 0 then
    -- Return default timesheet if file doesn't exist
    return {
      date = date,
      intervals = {},
      daily_total = "00:00"
    }
  end
  
  -- Load and execute the file
  local chunk = loadfile(file_path)
  if not chunk then
    error("failed to load timesheet file: " .. file_path)
  end
  
  local timesheet = chunk()
  return timesheet
end

-- Get all timesheet files in the data directory
function file_ops.get_all_timesheet_files()
  local data_dir = paths.get_data_dir()
  
  -- Check if directory exists
  if vim.fn.isdirectory(data_dir) == 0 then
    return {}
  end
  
  -- Get all .lua files in the directory
  local pattern = data_dir .. "/*.lua"
  local files = vim.fn.glob(pattern, false, true)
  
  -- Filter for timesheet files (YYYY-MM-DD.lua pattern)
  local timesheet_files = {}
  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":t")
    if filename:match("^%d%d%d%d%-%d%d%-%d%d%.lua$") then
      table.insert(timesheet_files, file)
    end
  end
  
  return timesheet_files
end

-- Delete all timesheet files
function file_ops.delete_all_timesheets()
  local files = file_ops.get_all_timesheet_files()
  local count = 0
  
  for _, file in ipairs(files) do
    if vim.fn.delete(file) == 0 then
      count = count + 1
    end
  end
  
  return count
end

return file_ops