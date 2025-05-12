-- epoch/storage.lua
-- file operations for epoch time tracking

local storage = {}
local config = require('epoch.config')
local popup = require('plenary.popup')

-- Template definitions for data structures
storage.templates = {
  -- Template for interval entries (as directly used in the UI)
  interval = {
    client = "",          -- client name (required)
    project = "",         -- project name (required)
    task = "",            -- task description (required)
    start = "",           -- start time in 12h format "HH:MM AM/PM" (required)
    ["end"] = "",         -- end time in 12h format "HH:MM AM/PM" (optional)
  },

  -- Template for timesheet entries
  timesheet = {
    date = "",             -- YYYY-MM-DD
    completed = false,     -- whether the timesheet is marked complete
    intervals = {},        -- array of interval entries
    daily_total = "00:00"  -- total time as HH:MM
  }
}

-- get the current date in YYYY-MM-DD format
function storage.get_today()
  return os.date('%Y-%m-%d')
end

-- get the path for a timesheet file based on date
function storage.get_timesheet_path(date)
  date = date or storage.get_today()
  return config.values.data_dir .. '/' .. date .. '.lua'
end

-- ensure data directory exists
function storage.ensure_data_dir()
  local dir_path = config.values.data_dir
  if vim.fn.isdirectory(dir_path) == 0 then
    vim.fn.mkdir(dir_path, "p")
  end
end

-- Create a new interval
function storage.create_interval(client, project, task, timestamp)
  -- Validate required fields
  if not client or client == "" then
    error("client cannot be empty")
  end

  if not project or project == "" then
    error("project cannot be empty")
  end

  if not task or task == "" then
    error("task cannot be empty")
  end

  -- Generate time from timestamp
  local current_time = timestamp or os.time()
  local formatted_time = os.date('%I:%M %p', current_time)

  -- Create interval using the template
  local interval = vim.deepcopy(storage.templates.interval)
  interval.client = client
  interval.project = project
  interval.task = task
  interval.start = formatted_time

  return interval
end

-- Check if time string is formatted correctly (12-hour format)
function storage.is_valid_time_format(time_str)
  if not time_str or time_str == "" then
    return false
  end

  -- Match pattern for "hh:mm AM/PM"
  return time_str:match("^%d%d?:%d%d [AP]M$") ~= nil
end

-- Validate interval structure
function storage.validate_interval(interval)
  if type(interval) ~= "table" then
    return false, "interval must be a table"
  end

  -- Check for required fields
  if not interval.client or interval.client == "" then
    return false, "client cannot be empty"
  end

  if not interval.project or interval.project == "" then
    return false, "project cannot be empty"
  end

  if not interval.task or interval.task == "" then
    return false, "task cannot be empty"
  end

  -- Validate start time format (must use 12-hour format with AM/PM)
  if not interval.start then
    return false, "start time is missing"
  end

  if not storage.is_valid_time_format(interval.start) then
    return false, string.format("start time '%s' must be in format 'HH:MM AM/PM'", interval.start)
  end

  -- If end time is provided, validate its format
  if interval["end"] and interval["end"] ~= "" and not storage.is_valid_time_format(interval["end"]) then
    return false, string.format("end time '%s' must be in format 'HH:MM AM/PM'", interval["end"])
  end

  return true
end

-- Create a default timesheet
function storage.create_default_timesheet(date)
  date = date or storage.get_today()

  return {
    date = date,
    completed = false,
    intervals = {},
    daily_total = "00:00"
  }
end

-- Validate timesheet structure
function storage.validate_timesheet(timesheet)
  if type(timesheet) ~= "table" then
    return false, "timesheet must be a table"
  end

  -- Ensure required fields exist, regardless of order
  if not timesheet.date then
    return false, "missing date field"
  end

  if timesheet.completed == nil then -- Allow false value
    return false, "missing completed field"
  end

  -- Ensure intervals is a table
  if type(timesheet.intervals) ~= "table" then
    return false, "intervals must be a table"
  end

  -- Validate each interval
  for i, interval in ipairs(timesheet.intervals) do
    local valid, msg = storage.validate_interval(interval)
    if not valid then
      -- Create a more descriptive error message with client/project info if available
      local context = ""
      if interval.client and interval.client ~= "" then
        context = context .. "client '" .. interval.client .. "'"
      end
      if interval.project and interval.project ~= "" then
        if context ~= "" then context = context .. ", " end
        context = context .. "project '" .. interval.project .. "'"
      end
      if interval.task and interval.task ~= "" then
        if context ~= "" then context = context .. ", " end
        context = context .. "task '" .. interval.task .. "'"
      end

      if context ~= "" then
        context = " (" .. context .. ")"
      end

      return false, "invalid interval at index " .. i .. context .. ": " .. msg
    end
  end

  return true
end

-- load a timesheet from file
function storage.load_timesheet(date)
  date = date or storage.get_today()
  local path = storage.get_timesheet_path(date)

  if vim.fn.filereadable(path) == 1 then
    local timesheet = dofile(path)

    -- Ensure intervals is always an array
    if not timesheet.intervals then
      timesheet.intervals = {}
    end

    -- Sort intervals by start time to ensure chronological order
    if #timesheet.intervals > 1 then
      storage.sort_intervals(timesheet.intervals)
    end

    return timesheet
  end

  -- return default empty timesheet
  return storage.create_default_timesheet(date)
end

-- Define key order for intervals
storage.interval_key_order = {"client", "project", "task", "start", "end"}

-- Sort intervals by their start time (chronological order)
function storage.sort_intervals(intervals)
  -- Helper function to convert 12-hour time format to comparable values
  local function time_value(time_str)
    if not time_str or time_str == "" then
      return 0 -- Default value for empty time
    end

    -- Parse hour, minute, and period (AM/PM)
    local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
    if not hour or not min or not period then
      return 0 -- Invalid format
    end

    -- Convert to numeric values
    hour = tonumber(hour)
    min = tonumber(min)

    -- Handle 12-hour format
    if period == "PM" and hour < 12 then
      hour = hour + 12
    elseif period == "AM" and hour == 12 then
      hour = 0
    end

    -- Return a comparable value (hours * 60 + minutes)
    return hour * 60 + min
  end

  -- Sort based on the numeric time value
  table.sort(intervals, function(a, b)
    return time_value(a.start) < time_value(b.start)
  end)

  return intervals
end

-- Serialize a Lua table with ordered keys
function storage.get_lua_table(tbl)
  -- Check if a table has sequential numeric indices
  local function is_array(t)
    local count = 0
    local max_index = 0

    for k, v in pairs(t) do
      if type(k) == "number" and k > 0 and math.floor(k) == k then
        count = count + 1
        max_index = math.max(max_index, k)
      else
        return false
      end
    end

    return count > 0 and count == max_index
  end

  -- Check if a table is an interval
  local function is_interval(t)
    return type(t) == "table" and
           t.client ~= nil and
           t.project ~= nil and
           t.task ~= nil and
           t.start ~= nil
  end

  -- Check if a table contains intervals
  local function is_intervals_array(t)
    if not is_array(t) or #t == 0 then
      return false
    end

    -- Check if first element looks like an interval
    return is_interval(t[1])
  end

  -- Serialize a value to Lua code
  local function serialize(val, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)

    if type(val) == "table" then
      local result = "{\n"

      if is_intervals_array(val) then
        -- Sort intervals by start time
        local sorted_intervals = {}
        for i=1, #val do
          sorted_intervals[i] = val[i]
        end
        storage.sort_intervals(sorted_intervals)

        -- Output intervals in sorted order with ordered keys
        for _, interval in ipairs(sorted_intervals) do
          result = result .. spaces .. "  {\n"

          -- Output keys in defined order
          for _, key in ipairs(storage.interval_key_order) do
            if interval[key] ~= nil then
              result = result .. spaces .. "    [\"" .. key .. "\"] = " .. serialize(interval[key], indent + 2) .. ",\n"
            end
          end

          result = result .. spaces .. "  },\n"
        end
      elseif is_array(val) then
        -- Handle other array-like tables
        for i=1, #val do
          result = result .. spaces .. "  " .. serialize(val[i], indent + 1) .. ",\n"
        end
      elseif is_interval(val) then
        -- Handle single interval with ordered keys
        for _, key in ipairs(storage.interval_key_order) do
          if val[key] ~= nil then
            result = result .. spaces .. "  [\"" .. key .. "\"] = " .. serialize(val[key], indent + 1) .. ",\n"
          end
        end
      else
        -- Handle regular tables
        for k, v in pairs(val) do
          local key = type(k) == "string" and "[\"" .. k .. "\"] = " or k .. " = "
          result = result .. spaces .. "  " .. key .. serialize(v, indent + 1) .. ",\n"
        end
      end

      result = result .. spaces .. "}"
      return result
    elseif type(val) == "string" then
      return "\"" .. val .. "\""
    else
      return tostring(val)
    end
  end

  return "return " .. serialize(tbl)
end

-- Checks for overlapping time intervals
function storage.check_overlapping_intervals(intervals, date)
  -- Skip check if there are less than 2 intervals
  if not intervals or #intervals < 2 then
    return false
  end

  -- Use provided date or fall back to today's date
  date = date or storage.get_today()

  -- First, sort the intervals themselves (use a copy)
  local sorted_intervals = vim.deepcopy(intervals)
  if #sorted_intervals >= 2 then
    storage.sort_intervals(sorted_intervals)
  end

  -- Create a new array of intervals with updated indices in sorted order
  local sorted = {}
  for i, interval in ipairs(sorted_intervals) do
    -- Only include intervals with both start and end times
    if interval.start and interval["end"] and interval["end"] ~= "" then
      table.insert(sorted, {
        index = i,  -- This is now the index in sorted order
        client = interval.client,
        project = interval.project,
        task = interval.task,
        start = interval.start,
        ["end"] = interval["end"],
      })
    end
  end

  -- Skip if not enough valid intervals
  if #sorted < 2 then
    return false
  end

  -- We need a function to convert time strings to seconds for comparison
  local function time_to_seconds(time_str, date_str)
    -- Skip invalid formats - validation happens elsewhere
    if not storage.is_valid_time_format(time_str) then
      return nil
    end
    
    local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
    if not hour or not min or not period then
      return nil
    end

    -- Convert to 24 hour format
    hour = tonumber(hour)
    min = tonumber(min)

    if period == "PM" and hour < 12 then
      hour = hour + 12
    elseif period == "AM" and hour == 12 then
      hour = 0
    end

    -- Get date components
    local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
    if not year or not month or not day then
      return nil
    end

    -- Create timestamp
    return os.time({
      year = tonumber(year),
      month = tonumber(month),
      day = tonumber(day),
      hour = hour,
      min = min
    })
  end

  -- We'll use our own time_value function for consistency with sort
  local function time_value(time_str)
    if not time_str or time_str == "" then
      return 0 -- Default value for empty time
    end

    -- Parse hour, minute, and period (AM/PM)
    local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
    if not hour or not min or not period then
      return 0 -- Invalid format
    end

    -- Convert to numeric values
    hour = tonumber(hour)
    min = tonumber(min)

    -- Handle 12-hour format
    if period == "PM" and hour < 12 then
      hour = hour + 12
    elseif period == "AM" and hour == 12 then
      hour = 0
    end

    -- Return a comparable value (hours * 60 + minutes)
    return hour * 60 + min
  end

  -- Check for overlaps in sorted intervals
  for i = 1, #sorted - 1 do
    local current = sorted[i]
    local next_interval = sorted[i + 1]

    -- Convert times to comparable values
    local current_end_val = time_value(current["end"])
    local next_start_val = time_value(next_interval.start)

    -- Check if current interval's end time is after next interval's start time
    if current_end_val > next_start_val then
        -- Create a more user-friendly error message without confusing indices
        return true, string.format(
          "intervals overlap: '%s/%s/%s' ends at %s but '%s/%s/%s' starts at %s",
          current.client, current.project, current.task, current["end"],
          next_interval.client, next_interval.project, next_interval.task, next_interval.start
        )
    end
  end

  -- No overlaps found
  return false
end

-- save a timesheet to file
function storage.save_timesheet(timesheet)
  storage.ensure_data_dir()
  local path = storage.get_timesheet_path(timesheet.date)

  -- Sort intervals by start time
  if timesheet.intervals and #timesheet.intervals > 1 then
    storage.sort_intervals(timesheet.intervals)
  end

  -- Format the timesheet as a Lua table string and save it
  local content = storage.get_lua_table(timesheet)
  vim.fn.writefile(vim.split(content, '\n'), path)
end

-- get all timesheet files
function storage.get_all_timesheet_files()
  storage.ensure_data_dir()
  local files = {}

  local handle = vim.loop.fs_scandir(config.values.data_dir)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then break end

      if type == "file" and name:match("%.lua$") then
        table.insert(files, config.values.data_dir .. "/" .. name)
      end
    end
  end

  return files
end

-- delete all timesheet files
function storage.delete_all_timesheets()
  local files = storage.get_all_timesheet_files()
  
  for _, file in ipairs(files) do
    vim.fn.delete(file)
  end
  
  return #files
end

return storage