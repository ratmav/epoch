-- models/timesheet/calculation.lua
-- Timesheet calculation operations

local calculation = {}
local interval_model = require('models.interval')
local time_service = require('services.time')

-- Calculate daily total from all completed intervals
function calculation.calculate_daily_total(this_timesheet)
  local total_minutes = 0

  for _, interval in ipairs(this_timesheet.intervals) do
    if interval_model.is_complete(interval) then
      total_minutes = total_minutes + interval_model.calculate_duration_minutes(interval)
    end
  end

  return time_service.format_duration(total_minutes)
end

-- Update timesheet's daily total
function calculation.update_daily_total(this_timesheet)
  this_timesheet.daily_total = calculation.calculate_daily_total(this_timesheet)
end

return calculation
