-- models/interval/creation.lua
-- Interval creation and lifecycle management

local creation = {}
local time_service = require('epoch.services.time')

-- Create a new interval with required fields
function creation.create(client, project, task, start_time)
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
function creation.close(this_interval, stop_time)
  if not creation.is_open(this_interval) then
    return false
  end

  stop_time = stop_time or time_service.format_current_time()
  this_interval.stop = stop_time

  if this_interval.notes == nil then
    this_interval.notes = {}
  end

  return true
end

-- Check if interval is open (no stop time)
function creation.is_open(this_interval)
  return not this_interval.stop or this_interval.stop == ""
end

return creation
