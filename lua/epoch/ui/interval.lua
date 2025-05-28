-- epoch/ui/interval.lua
-- Interval creation and manipulation operations

local time_utils = require('epoch.time_utils')
local validation = require('epoch.validation')

local interval = {}

-- Create a new interval to track time
-- Returns: interval object
function interval.create(client, project, task, start_time, notes)
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
function interval.close_current(timesheet, stop_time)
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
function interval.add_to_timesheet(timesheet, new_interval)
  -- Make a copy to avoid modifying the original
  local updated = vim.deepcopy(timesheet)
  
  -- Close any unclosed interval
  interval.close_current(updated)
  
  -- Add the new interval
  table.insert(updated.intervals, new_interval)
  
  return updated
end

-- Validate timesheet input for calculation
local function validate_timesheet_input(timesheet)
  if not timesheet or not timesheet.intervals then
    return false
  end
  return true
end

-- Check if interval has both start and stop times
local function is_complete_interval(interval)
  return interval.start and interval.stop and interval.stop ~= ""
end

-- Calculate minutes for a single interval
local function calculate_interval_minutes(interval)
  if not time_utils.is_valid_time_format(interval.start) or not time_utils.is_valid_time_format(interval.stop) then
    return 0
  end
  
  local start_value = validation.time_value(interval.start)
  local stop_value = validation.time_value(interval.stop)
  
  if start_value and stop_value and stop_value > start_value then
    return math.floor((stop_value - start_value) / 60)
  end
  
  return 0
end

-- Calculate daily total duration from intervals
-- Returns: formatted duration string (HH:MM)
function interval.calculate_daily_total(timesheet)
  if not validate_timesheet_input(timesheet) then
    return "00:00"
  end

  local total_minutes = 0
  for _, current_interval in ipairs(timesheet.intervals) do
    if is_complete_interval(current_interval) then
      total_minutes = total_minutes + calculate_interval_minutes(current_interval)
    end
  end

  return time_utils.format_duration(total_minutes)
end

-- Validate timing inputs and return last interval
local function validate_timing_inputs(timesheet)
  if not timesheet.intervals or #timesheet.intervals == 0 then
    return nil
  end
  return timesheet.intervals[#timesheet.intervals]
end

-- Handle timing for unclosed intervals
local function handle_unclosed_interval(last_interval, current_time)
  local last_start_time = time_utils.parse_time(last_interval.start)
  
  -- Ensure at least 1 minute difference
  if current_time - last_start_time < 60 then
    local adjusted_previous_stop = time_utils.format_time(last_start_time + 60)
    local adjusted_current = last_start_time + 120 -- Start new interval 1 minute after previous ends
    return adjusted_current, adjusted_previous_stop
  else
    local adjusted_previous_stop = time_utils.format_time(current_time)
    local adjusted_current = current_time + 60 -- Start new interval 1 minute after current time
    return adjusted_current, adjusted_previous_stop
  end
end

-- Handle timing for closed intervals
local function handle_closed_interval(last_interval, current_time)
  local last_stop_time = time_utils.parse_time(last_interval.stop)
  if current_time <= last_stop_time then
    return last_stop_time + 60, nil
  end
  return current_time, nil
end

-- Handle interval timing conflicts and adjustments
-- Returns: adjusted_start_time, adjusted_stop_time_for_previous
function interval.resolve_timing(timesheet, current_time)
  local last_interval = validate_timing_inputs(timesheet)
  if not last_interval then
    return current_time, nil
  end
  
  -- Handle based on whether last interval is closed or not
  if not last_interval.stop or last_interval.stop == "" then
    return handle_unclosed_interval(last_interval, current_time)
  else
    return handle_closed_interval(last_interval, current_time)
  end
end

return interval