-- epoch/timesheet/calculation.lua
-- Pure timesheet calculation functions

local interval_calculation = require('epoch.interval.calculation')

local calculation = {}

-- Recalculate hours field for all complete intervals in timesheet
function calculation.recalculate_interval_hours(timesheet_data)
  if not timesheet_data.intervals then
    return timesheet_data
  end

  local updated = vim.deepcopy(timesheet_data)
  for _, interval in ipairs(updated.intervals) do
    if interval.start and interval.stop and interval.stop ~= "" then
      interval.hours = interval_calculation.calculate_interval_hours(interval)
    end
  end

  return updated
end

-- Update daily total in a timesheet
function calculation.update_daily_total(timesheet_data, calculate_fn)
  local updated = vim.deepcopy(timesheet_data)
  updated.daily_total = calculate_fn(updated)
  return updated
end

return calculation