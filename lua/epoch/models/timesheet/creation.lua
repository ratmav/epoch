-- models/timesheet/creation.lua
-- Timesheet creation and interval management

local creation = {}
local interval_model = require('epoch.models.interval')
local time_service = require('epoch.services.time')

-- Create a new timesheet for a date
function creation.create(date)
  date = date or os.date("%Y-%m-%d")

  return {
    date = date,
    intervals = {},
    daily_total = "00:00"
  }
end

-- Private: close last interval (assumes it exists and is open)
local function close_last_interval(this_timesheet, stop_time)
  local last_interval = this_timesheet.intervals[#this_timesheet.intervals]
  return interval_model.close(last_interval, stop_time)
end

-- Close the most recent open interval in timesheet
function creation.close_current_interval(this_timesheet, stop_time)
  if #this_timesheet.intervals == 0 then
    return false
  end

  local last_interval = this_timesheet.intervals[#this_timesheet.intervals]
  if not interval_model.is_open(last_interval) then
    return false
  end

  return close_last_interval(this_timesheet, stop_time)
end

-- Add interval to timesheet and update totals
function creation.add_interval(this_timesheet, interval)
  -- Close any open interval first (business rule: only one open interval per timesheet)
  local current_time = time_service.format_current_time()
  creation.close_current_interval(this_timesheet, current_time)

  table.insert(this_timesheet.intervals, interval)
end

return creation
