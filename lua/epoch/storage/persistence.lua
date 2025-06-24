-- epoch/storage/persistence.lua
-- Timesheet save and load operations

local persistence = {}
local paths = require('epoch.storage.paths')
local serializer = require('epoch.storage.serializer')

-- Create default timesheet for date
local function create_default_timesheet(date)
  return {
    date = date,
    intervals = {},
    daily_total = "00:00"
  }
end

-- Load timesheet file content
local function load_timesheet_file(file_path)
  local chunk = loadfile(file_path)
  if not chunk then
    error("failed to load timesheet file: " .. file_path)
  end
  return chunk()
end

local function validate_timesheet(timesheet)
  if not timesheet or not timesheet.date then
    return false, "invalid timesheet data"
  end
  return true, nil
end

local function write_file_content(file_path, content)
  local file = io.open(file_path, 'w')
  if not file then
    error("could not open file for writing: " .. file_path)
  end
  file:write(content)
  file:close()
end

-- Save a timesheet to disk
function persistence.save_timesheet(timesheet)
  local valid, err = validate_timesheet(timesheet)
  if not valid then
    return false, err
  end

  paths.ensure_data_dir()
  local file_path = paths.get_timesheet_path(timesheet.date)
  local content = serializer.serialize_timesheet(timesheet)

  local success, write_err = pcall(write_file_content, file_path, content)
  return success, write_err
end

-- Load a timesheet from disk
function persistence.load_timesheet(date)
  date = date or paths.get_today()
  local file_path = paths.get_timesheet_path(date)

  if vim.fn.filereadable(file_path) == 0 then
    return create_default_timesheet(date)
  end

  return load_timesheet_file(file_path)
end

-- Create default timesheet for given date (public API)
function persistence.create_default_timesheet(date)
  return create_default_timesheet(date or paths.get_today())
end

return persistence
