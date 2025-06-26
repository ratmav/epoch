-- models/interval.lua
-- Domain model for time tracking intervals

local interval = {}
local time_service = require('services.time')

-- Create a new interval with required fields
function interval.create(client, project, task, start_time)
  start_time = start_time or time_service.format_current_time()
  
  return {
    client = client,
    project = project,
    task = task,
    start = start_time,
    stop = "",
    notes = {}
  }
end

-- Close an interval with stop time
function interval.close(interval_obj, stop_time)
  if not interval.is_open(interval_obj) then
    return false
  end
  
  stop_time = stop_time or time_service.format_current_time()
  interval_obj.stop = stop_time
  
  if interval_obj.notes == nil then
    interval_obj.notes = {}
  end
  
  return true
end

-- Check if interval is open (no stop time)
function interval.is_open(interval_obj)
  return not interval_obj.stop or interval_obj.stop == ""
end

-- Check if interval has all required fields and is closed
function interval.is_complete(interval_obj)
  if not interval_obj.client or 
     not interval_obj.project or 
     not interval_obj.task or 
     not interval_obj.start then
    return false
  end
  
  return not interval.is_open(interval_obj)
end

-- Calculate duration in minutes for completed intervals
function interval.calculate_duration_minutes(interval_obj)
  if not interval.is_complete(interval_obj) then
    return 0
  end
  
  if not time_service.is_valid_format(interval_obj.start) or 
     not time_service.is_valid_format(interval_obj.stop) then
    return 0
  end
  
  local start_value = time_service.to_minutes_since_midnight(interval_obj.start)
  local stop_value = time_service.to_minutes_since_midnight(interval_obj.stop)
  
  if start_value and stop_value and stop_value > start_value then
    return stop_value - start_value
  end
  
  return 0
end

return interval