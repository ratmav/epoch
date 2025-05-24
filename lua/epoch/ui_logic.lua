-- epoch/ui_logic.lua
-- Core logic for UI functionality, extracted for better testability

local ui_logic = {}
local time_utils = require('epoch.time_utils')
local validation = require('epoch.validation')

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
function ui_logic.create_interval(client, project, task, start_time)
  start_time = start_time or os.time()
  local formatted_time = time_utils.format_time(start_time)
  
  return {
    client = client,
    project = project,
    task = task,
    start = formatted_time,
    stop = ""
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

return ui_logic