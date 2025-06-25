-- epoch/report/week_utils.lua
-- Week calculation utilities for report generation

local week_utils = {}
local date_calculation = require('epoch.report.week_utils.date_calculation')
local range_calculation = require('epoch.report.week_utils.range_calculation')
local interval_calculation = require('epoch.report.week_utils.interval_calculation')

-- Get week number from date string (YYYY-MM-DD)
function week_utils.get_week_number(date_str)
  return date_calculation.get_week_number(date_str)
end

-- Get week date range from week number string (YYYY-WW)
function week_utils.get_week_date_range(week_str)
  return range_calculation.get_week_date_range(week_str)
end

-- Get hours from completed interval
function week_utils.get_interval_hours(interval)
  return interval_calculation.get_interval_hours(interval)
end

return week_utils