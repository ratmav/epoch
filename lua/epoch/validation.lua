-- epoch/validation.lua
-- validation functions for epoch time tracking

local validation = {}
local time_utils = require('epoch.time_utils')

-- validate interval structure
function validation.validate_interval(interval)
  if type(interval) ~= "table" then
    return false, "interval must be a table"
  end

  -- check for required fields
  if interval.client == nil or interval.client == "" then
    return false, "client cannot be empty"
  end

  if interval.project == nil or interval.project == "" then
    return false, "project cannot be empty"
  end

  if interval.task == nil or interval.task == "" then
    return false, "task cannot be empty"
  end

  -- validate start time format (must use 12-hour format with AM/PM)
  if not interval.start then
    return false, "start time is missing"
  end

  if not time_utils.is_valid_time_format(interval.start) then
    return false, string.format("start time '%s' must be in format 'HH:MM AM/PM'", interval.start)
  end

  -- if stop time is provided, validate its format
  if interval.stop and interval.stop ~= "" and not time_utils.is_valid_time_format(interval.stop) then
    return false, string.format("stop time '%s' must be in format 'HH:MM AM/PM'", interval.stop)
  end

  return true
end

-- validate timesheet structure
function validation.validate_timesheet(timesheet)
  if type(timesheet) ~= "table" then
    return false, "timesheet must be a table"
  end

  -- ensure required fields exist
  if not timesheet.date then
    return false, "missing date field"
  end

  -- ensure intervals is a table
  if type(timesheet.intervals) ~= "table" then
    return false, "intervals must be a table"
  end

  -- validate each interval
  for i, interval in ipairs(timesheet.intervals) do
    local valid, msg = validation.validate_interval(interval)
    if not valid then
      -- create a more descriptive error message with client/project info
      local context = validation.get_interval_context(interval)
      
      if context ~= "" then
        context = " (" .. context .. ")"
      end

      return false, "invalid interval at index " .. i .. context .. ": " .. msg
    end
  end

  -- check for overlapping intervals
  local overlapping, msg = validation.check_overlapping_intervals(timesheet.intervals, timesheet.date)
  if overlapping then
    return false, msg
  end

  return true
end

-- helper to get interval context for error messages
function validation.get_interval_context(interval)
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
  
  return context
end

-- helper to convert time strings to comparable values
function validation.time_value(time_str)
  if not time_str or time_str == "" then
    return 0 -- default value for empty time
  end

  -- parse hour, minute, and period (AM/PM)
  local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
  if not hour or not min or not period then
    return 0 -- invalid format
  end

  -- convert to numeric values
  hour = tonumber(hour)
  min = tonumber(min)

  -- handle 12-hour format
  if period == "PM" and hour < 12 then
    hour = hour + 12
  elseif period == "AM" and hour == 12 then
    hour = 0
  end

  -- return a comparable value (hours * 60 + minutes)
  return hour * 60 + min
end

-- checks for overlapping time intervals
function validation.check_overlapping_intervals(intervals, date)
  -- skip check if there are less than 2 intervals
  if not intervals or #intervals < 2 then
    return false
  end

  -- use provided date or fall back to today's date
  date = date or os.date("%Y-%m-%d")

  -- first, sort the intervals (use a copy)
  local sorted_intervals = {}
  for i, interval in ipairs(intervals) do
    table.insert(sorted_intervals, interval)
  end
  
  -- sort by start time
  table.sort(sorted_intervals, function(a, b)
    return validation.time_value(a.start) < validation.time_value(b.start)
  end)

  -- Check for overlaps
  for i = 1, #sorted_intervals - 1 do
    local current = sorted_intervals[i]
    
    -- Skip intervals without start time (invalid intervals)
    if not current.start then
      goto continue
    end
    
    -- Track current interval's stop boundary
    local current_stop_value
    
    -- For closed intervals, use the stop time
    if current.stop and current.stop ~= "" then
      current_stop_value = validation.time_value(current.stop)
    else
      -- For unclosed intervals, assume it extends indefinitely 
      -- (this means any interval that starts after this one will overlap)
      current_stop_value = 24 * 60  -- End of day (midnight)
    end
    
    -- Check against all subsequent intervals
    for j = i + 1, #sorted_intervals do
      local next_interval = sorted_intervals[j]
      
      -- Skip invalid next interval
      if not next_interval.start then
        goto next_interval
      end
      
      local next_start_value = validation.time_value(next_interval.start)
      
      -- If next interval starts before current interval ends, we have an overlap
      if next_start_value < current_stop_value then
        -- Format appropriate error message based on whether the current interval is closed
        if current.stop and current.stop ~= "" then
          return true, string.format(
            "intervals overlap: '%s/%s/%s' ends at %s but '%s/%s/%s' starts at %s",
            current.client, current.project, current.task, current.stop,
            next_interval.client, next_interval.project, next_interval.task, next_interval.start
          )
        else
          return true, string.format(
            "intervals overlap: '%s/%s/%s' has no end time but '%s/%s/%s' starts at %s",
            current.client, current.project, current.task,
            next_interval.client, next_interval.project, next_interval.task, next_interval.start
          )
        end
      end
      
      ::next_interval::
    end
    
    ::continue::
  end

  -- no overlaps found
  return false
end

return validation