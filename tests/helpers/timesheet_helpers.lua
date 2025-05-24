-- timesheet_helpers.lua
-- helper functions for working with timesheets in tests

local timesheet_helpers = {}

local time_fixtures = require('tests.fixtures.time_fixtures')

-- Helper function to create a base timesheet
function timesheet_helpers.create_timesheet(date, intervals, daily_total)
  return {
    date = date or time_fixtures.dates.valid.today,
    intervals = intervals or {},
    daily_total = daily_total or "00:00"
  }
end

-- Calculate a reasonable daily total if not provided
function timesheet_helpers.calculate_daily_total(intervals)
  if not intervals or #intervals == 0 then
    return "00:00"
  end
  
  local total
  if #intervals == 1 then
    total = "01:30" -- Approximation for a typical interval
  elseif #intervals == 2 then
    total = "03:00" -- Two typical intervals
  else
    total = string.format("%02d:00", #intervals) -- Rough estimate
  end
  
  return total
end

return timesheet_helpers