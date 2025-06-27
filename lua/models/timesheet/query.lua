-- models/timesheet/query.lua
-- Timesheet query operations

local query = {}
local interval_model = require('models.interval')

-- Check if timesheet has any open intervals
function query.has_open_interval(this_timesheet)
  for _, interval in ipairs(this_timesheet.intervals) do
    if interval_model.is_open(interval) then
      return true
    end
  end
  return false
end

-- Get only completed intervals from timesheet
function query.get_completed_intervals(this_timesheet)
  local completed = {}

  for _, interval in ipairs(this_timesheet.intervals) do
    if interval_model.is_complete(interval) then
      table.insert(completed, interval)
    end
  end

  return completed
end

-- Get timesheets within date range (collection operation)
function query.get_by_date_range(timesheets, start_date, end_date)
  if not start_date or not end_date then
    return timesheets
  end

  local filtered = {}
  for _, this_timesheet in ipairs(timesheets) do
    if this_timesheet.date >= start_date and this_timesheet.date <= end_date then
      table.insert(filtered, this_timesheet)
    end
  end

  return filtered
end

return query
