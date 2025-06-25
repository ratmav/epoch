-- epoch/report.lua
-- reporting functionality for epoch time tracking
-- coverage: no tests

local report = {}
local generator = require('epoch.report.generator')
local formatter = require('epoch.report.formatter')

-- Public API: Get all timesheet dates
function report.get_all_timesheet_dates()
  return generator.get_all_timesheet_dates()
end

-- Public API: Generate a report for all timesheets
function report.generate_report()
  return generator.generate_report()
end

-- Public API: Format the report as a string for display
function report.format_report(report_data)
  return formatter.format_report(report_data)
end

return report