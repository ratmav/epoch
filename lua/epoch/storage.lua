-- epoch/storage.lua
-- storage operations for epoch time tracking

local storage = {}
local validation = require('epoch.validation')

-- Default data directory
local data_dir = vim.fn.stdpath('data') .. '/epoch'

-- Set the data directory (useful for testing)
function storage.set_data_dir(path)
  data_dir = path
end

-- Set the data directory specifically for tests
function storage._set_data_dir_for_tests(path)
  data_dir = path
end

-- Get the current data directory
function storage.get_data_dir()
  return data_dir
end

-- Get today's date in YYYY-MM-DD format
function storage.get_today()
  return os.date('%Y-%m-%d')
end

-- Get the path for a timesheet file based on date
function storage.get_timesheet_path(date)
  date = date or storage.get_today()
  return data_dir .. '/' .. date .. '.lua'
end

-- Ensure data directory exists
function storage.ensure_data_dir()
  if vim.fn.isdirectory(data_dir) == 0 then
    vim.fn.mkdir(data_dir, "p")
  end
end

-- Create a default timesheet for a given date
function storage.create_default_timesheet(date)
  date = date or storage.get_today()
  
  return {
    date = date,
    intervals = {},
    daily_total = "00:00"
  }
end

-- Define key order for intervals to ensure consistent serialization
local interval_key_order = {"client", "project", "task", "start", "stop", "notes"}

-- Check if table is a list (array) with sequential numeric indices
local function is_array(tbl)
  if type(tbl) ~= "table" then return false end
  
  local count = 0
  local max_index = 0
  
  for k, _ in pairs(tbl) do
    if type(k) ~= "number" or k <= 0 or math.floor(k) ~= k then
      return false
    end
    count = count + 1
    max_index = math.max(max_index, k)
  end
  
  return count > 0 and count == max_index
end

-- Helper function to serialize a Lua table with ordered keys
local function serialize_table(tbl, indent)
  indent = indent or 0
  local spaces = string.rep("  ", indent)
  local result = "{\n"
  
  -- Handle different table types differently
  if is_array(tbl) then
    -- It's a list/array, preserve order
    for _, value in ipairs(tbl) do
      if type(value) == "table" then
        result = result .. spaces .. "  " .. serialize_table(value, indent + 1) .. ",\n"
      elseif type(value) == "string" then
        result = result .. spaces .. "  \"" .. value .. "\",\n"
      else
        result = result .. spaces .. "  " .. tostring(value) .. ",\n"
      end
    end
  else
    -- Handle interval specially for key ordering
    if tbl.client and tbl.project and tbl.task and tbl.start then
      -- This looks like an interval - use predefined key order
      for _, key in ipairs(interval_key_order) do
        if tbl[key] ~= nil then
          result = result .. spaces .. "  [\"" .. key .. "\"] = "
          
          if type(tbl[key]) == "table" then
            result = result .. serialize_table(tbl[key], indent + 1)
          elseif type(tbl[key]) == "string" then
            result = result .. "\"" .. tbl[key] .. "\""
          else
            result = result .. tostring(tbl[key])
          end
          
          result = result .. ",\n"
        end
      end
    else
      -- Normal table - sort keys for consistency
      local keys = {}
      for k in pairs(tbl) do
        table.insert(keys, k)
      end
      table.sort(keys)
      
      for _, k in ipairs(keys) do
        local v = tbl[k]
        if type(k) == "string" then
          result = result .. spaces .. "  [\"" .. k .. "\"] = "
        else
          result = result .. spaces .. "  [" .. tostring(k) .. "] = "
        end
        
        if type(v) == "table" then
          result = result .. serialize_table(v, indent + 1)
        elseif type(v) == "string" then
          result = result .. "\"" .. v .. "\""
        else
          result = result .. tostring(v)
        end
        
        result = result .. ",\n"
      end
    end
  end
  
  result = result .. spaces .. "}"
  return result
end

-- Sort intervals in a timesheet by start time
local function sort_intervals(timesheet)
  if not timesheet.intervals or #timesheet.intervals <= 1 then
    return timesheet
  end
  
  local sorted = {}
  for _, interval in ipairs(timesheet.intervals) do
    table.insert(sorted, interval)
  end
  
  table.sort(sorted, function(a, b)
    return validation.time_value(a.start) < validation.time_value(b.start)
  end)
  
  local result = vim.deepcopy(timesheet)
  result.intervals = sorted
  return result
end

-- Serialize a timesheet to Lua code
function storage.serialize_timesheet(timesheet)
  -- Sort intervals by start time
  timesheet = sort_intervals(timesheet)
  
  -- Return the serialized table with 'return' prefix for loadable format
  return "return " .. serialize_table(timesheet)
end

-- Save a timesheet to file
-- Note: This function assumes the timesheet has already been validated
function storage.save_timesheet(timesheet)
  storage.ensure_data_dir()
  local path = storage.get_timesheet_path(timesheet.date)
  
  -- Sort intervals by start time
  timesheet = sort_intervals(timesheet)
  
  -- Format as Lua and write to file
  local content = storage.serialize_timesheet(timesheet)
  
  -- Write to file and check result
  local success, err = pcall(function()
    vim.fn.writefile(vim.split(content, '\n'), path)
  end)
  
  return success, err
end

-- Load a timesheet from file
function storage.load_timesheet(date)
  date = date or storage.get_today()
  local path = storage.get_timesheet_path(date)
  
  if vim.fn.filereadable(path) == 1 then
    -- Use protected call to handle syntax errors
    local ok, timesheet = pcall(dofile, path)
    
    if ok and type(timesheet) == "table" then
      -- Ensure intervals is always a table
      if not timesheet.intervals then
        timesheet.intervals = {}
      end
      
      -- Sort intervals by start time
      return sort_intervals(timesheet)
    end
  end
  
  -- Return default empty timesheet if file doesn't exist or is invalid
  return storage.create_default_timesheet(date)
end

-- Get all timesheet files in the data directory
function storage.get_all_timesheet_files()
  storage.ensure_data_dir()
  local files = {}
  
  local handle = vim.loop.fs_scandir(data_dir)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then break end
      
      if type == "file" and name:match("%.lua$") then
        table.insert(files, data_dir .. "/" .. name)
      end
    end
  end
  
  return files
end

-- Delete all timesheet files
function storage.delete_all_timesheets()
  local files = storage.get_all_timesheet_files()
  
  for _, file in ipairs(files) do
    vim.fn.delete(file)
  end
  
  return #files
end

return storage