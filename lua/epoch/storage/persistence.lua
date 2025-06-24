-- epoch/storage/persistence.lua
-- Timesheet save and load operations

local persistence = {}
local paths = require('epoch.storage.paths')
local serializer = require('epoch.storage.serializer')

-- Create default timesheet for date
function persistence.create_default_timesheet(date)
  date = date or paths.get_today()
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

-- Deserialize Lua content string to timesheet data
function persistence.deserialize_content(content)
  local chunk, err = loadstring(content, "timesheet")
  if not chunk then
    return nil, "lua syntax error: " .. tostring(err)
  end

  local ok, timesheet_data = pcall(chunk)
  if not ok then
    return nil, "execution error: " .. tostring(timesheet_data)
  end

  return timesheet_data, nil
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
    return persistence.create_default_timesheet(date)
  end

  return load_timesheet_file(file_path)
end

-- Load raw timesheet file content as string
function persistence.load_timesheet_content(timesheet_path)
  return table.concat(vim.fn.readfile(timesheet_path), '\n')
end

return persistence
