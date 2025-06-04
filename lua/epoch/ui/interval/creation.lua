-- epoch/ui/interval/creation.lua
-- Basic interval creation and manipulation

local time_utils = require('epoch.time_utils')

local creation = {}

-- Create a new interval to track time
-- Returns: interval object
function creation.create(client, project, task, start_time)
  start_time = start_time or os.time()
  local formatted_time = time_utils.format_time(start_time)

  return {
    client = client,
    project = project,
    task = task,
    start = formatted_time,
    stop = "",
    notes = {}
  }
end

-- Validate timesheet for closing operation
local function validate_timesheet_for_close(timesheet)
  return timesheet and timesheet.intervals and #timesheet.intervals > 0
end

-- Close interval with formatted time
local function close_interval_with_time(interval, stop_time)
  local formatted_time = stop_time or time_utils.format_time(os.time())
  interval.stop = formatted_time

  if interval.notes == nil then
    interval.notes = {}
  end
end

-- Close the most recent unclosed interval in a timesheet
-- Returns: true if an interval was closed, false otherwise
function creation.close_current(timesheet, stop_time)
  if not validate_timesheet_for_close(timesheet) then
    return false
  end

  local last_interval = timesheet.intervals[#timesheet.intervals]

  if not last_interval.stop or last_interval.stop == "" then
    close_interval_with_time(last_interval, stop_time)
    return true
  end

  return false
end


return creation