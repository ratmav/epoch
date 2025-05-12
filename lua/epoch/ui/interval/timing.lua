-- epoch/ui/interval/timing.lua
-- Timing conflict resolution

local time_utils = require('epoch.time_utils')

local timing = {}

-- Validate timing inputs and return last interval
local function validate_timing_inputs(timesheet)
  if not timesheet.intervals or #timesheet.intervals == 0 then
    return nil
  end
  return timesheet.intervals[#timesheet.intervals]
end

-- Validate start time parsing
local function validate_start_time(start_time_str)
  local parsed_time = time_utils.parse_time(start_time_str)
  if not parsed_time then
    error("Failed to parse start time: " .. tostring(start_time_str))
  end
  return parsed_time
end

-- Calculate timing for close intervals
local function calculate_close_timing(last_start_time)
  local adjusted_previous_stop = time_utils.format_time(last_start_time + 60)
  local adjusted_current = last_start_time + 120
  return adjusted_current, adjusted_previous_stop
end

-- Calculate timing for gap intervals
local function calculate_gap_timing(current_time)
  local adjusted_previous_stop = time_utils.format_time(current_time)
  local adjusted_current = current_time + 60
  return adjusted_current, adjusted_previous_stop
end

-- Handle timing for unclosed intervals
local function handle_unclosed_interval(last_interval, current_time)
  local last_start_time = validate_start_time(last_interval.start)

  if current_time - last_start_time < 60 then
    return calculate_close_timing(last_start_time)
  else
    return calculate_gap_timing(current_time)
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
function timing.resolve_timing(timesheet, current_time)
  local last_interval = validate_timing_inputs(timesheet)
  if not last_interval then
    return current_time, nil
  end

  if not last_interval.stop or last_interval.stop == "" then
    return handle_unclosed_interval(last_interval, current_time)
  else
    return handle_closed_interval(last_interval, current_time)
  end
end

return timing