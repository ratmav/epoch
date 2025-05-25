-- epoch/ui_logic.lua
-- Core logic for UI functionality, extracted for better testability

local ui_logic = {}
local time_utils = require('epoch.time_utils')
local validation = require('epoch.validation')
local storage = require('epoch.storage')

-- Validate and prepare timesheet content
-- Returns: timesheet, nil on success OR nil, error_message on failure
function ui_logic.validate_timesheet_content(content)
  -- Use protected call to load and execute the Lua content
  local chunk, err = loadstring(content, "timesheet")
  if not chunk then
    return nil, "lua syntax error: " .. tostring(err)
  end
  
  local ok, timesheet = pcall(chunk)
  if not ok then
    return nil, "execution error: " .. tostring(timesheet)
  end
  
  if type(timesheet) ~= "table" then
    return nil, "invalid timesheet format (not a table)"
  end
  
  -- Validate timesheet structure
  local valid, validation_err = validation.validate_timesheet(timesheet)
  if not valid then
    return nil, validation_err
  end
  
  return timesheet, nil
end

-- Create a new interval to track time
-- Returns: interval object
function ui_logic.create_interval(client, project, task, start_time, notes)
  start_time = start_time or os.time()
  local formatted_time = time_utils.format_time(start_time)
  
  return {
    client = client,
    project = project,
    task = task,
    start = formatted_time,
    stop = "",
    notes = {}  -- Notes field is always an array of strings
  }
end

-- Close the most recent unclosed interval in a timesheet
-- Returns: true if an interval was closed, false otherwise
function ui_logic.close_current_interval(timesheet, stop_time)
  if not timesheet or not timesheet.intervals or #timesheet.intervals == 0 then
    return false
  end
  
  -- Find the last interval
  local last_interval = timesheet.intervals[#timesheet.intervals]
  
  -- Check if it's unclosed
  if not last_interval.stop or last_interval.stop == "" then
    -- Close it with the provided or current time
    local formatted_time = stop_time or time_utils.format_time(os.time())
    last_interval.stop = formatted_time
    
    -- Ensure notes field exists
    if last_interval.notes == nil then
      last_interval.notes = {}
    end
    
    return true
  end
  
  return false
end

-- Add a new interval to the timesheet
-- If there's an unclosed interval, it will be closed first
-- Returns: updated timesheet
function ui_logic.add_interval_to_timesheet(timesheet, interval)
  -- Make a copy to avoid modifying the original
  local updated = vim.deepcopy(timesheet)
  
  -- Close any unclosed interval
  ui_logic.close_current_interval(updated)
  
  -- Add the new interval
  table.insert(updated.intervals, interval)
  
  return updated
end

-- Calculate daily total duration from intervals
-- Returns: formatted duration string (HH:MM)
function ui_logic.calculate_daily_total(timesheet)
  if not timesheet or not timesheet.intervals then
    return "00:00"
  end

  local total_minutes = 0

  for _, interval in ipairs(timesheet.intervals) do
    -- Only count intervals that have both start and stop times
    -- Skip unclosed intervals (where stop is empty or nil)
    if interval.start and interval.stop and interval.stop ~= "" then
      -- Validate time formats before calculating
      if time_utils.is_valid_time_format(interval.start) and time_utils.is_valid_time_format(interval.stop) then
        -- Convert to time values using validation helper
        local start_value = validation.time_value(interval.start)
        local stop_value = validation.time_value(interval.stop)

        -- Calculate minutes if both times are valid and stop is after start
        if start_value and stop_value and stop_value > start_value then
          local minutes = math.floor((stop_value - start_value) / 60)
          total_minutes = total_minutes + minutes
        end
      end
    end
  end

  return time_utils.format_duration(total_minutes)
end

-- Update daily total in a timesheet
-- Returns: updated timesheet
function ui_logic.update_daily_total(timesheet)
  local updated = vim.deepcopy(timesheet)
  updated.daily_total = ui_logic.calculate_daily_total(updated)
  return updated
end

-- Handle interval timing conflicts and adjustments
-- Returns: adjusted_start_time, adjusted_stop_time_for_previous
function ui_logic.resolve_interval_timing(timesheet, current_time)
  if not timesheet.intervals or #timesheet.intervals == 0 then
    return current_time, nil
  end
  
  local last_interval = timesheet.intervals[#timesheet.intervals]
  local adjusted_current = current_time
  local adjusted_previous_stop = nil
  
  -- If last interval is unclosed, we need to close it
  if not last_interval.stop or last_interval.stop == "" then
    local last_start_time = time_utils.parse_time(last_interval.start)
    
    -- Ensure at least 1 minute difference
    if current_time - last_start_time < 60 then
      adjusted_previous_stop = time_utils.format_time(last_start_time + 60)
      adjusted_current = last_start_time + 120 -- Start new interval 1 minute after previous ends
    else
      adjusted_previous_stop = time_utils.format_time(current_time)
      adjusted_current = current_time + 60 -- Start new interval 1 minute after current time
    end
  else
    -- Previous interval is closed, check if we need to adjust start time
    local last_stop_time = time_utils.parse_time(last_interval.stop)
    if current_time <= last_stop_time then
      adjusted_current = last_stop_time + 60
    end
  end
  
  return adjusted_current, adjusted_previous_stop
end

-- Complete workflow for adding an interval with all business logic
-- Returns: success, error_message, updated_timesheet
function ui_logic.add_interval_workflow(client, project, task, timesheet)
  if not client or client == "" then
    return false, "client is required", nil
  end
  if not project or project == "" then
    return false, "project is required", nil
  end
  if not task or task == "" then
    return false, "task is required", nil
  end
  
  local current_time = os.time()
  local updated_timesheet = vim.deepcopy(timesheet)
  
  -- Handle timing conflicts and close previous interval if needed
  local adjusted_start, previous_stop = ui_logic.resolve_interval_timing(updated_timesheet, current_time)
  
  -- Close previous interval if needed
  if previous_stop then
    ui_logic.close_current_interval(updated_timesheet, previous_stop)
  end
  
  -- Create new interval
  local interval = ui_logic.create_interval(client, project, task, adjusted_start)
  table.insert(updated_timesheet.intervals, interval)
  
  -- Update daily total
  updated_timesheet = ui_logic.update_daily_total(updated_timesheet)
  
  return true, nil, updated_timesheet
end

return ui_logic