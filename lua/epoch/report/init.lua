-- epoch/report.lua
-- reporting functionality for epoch time tracking

local report = {}
local generator = require('epoch.report.generator')
local formatter = require('epoch.report.formatter')
local window = require('epoch.ui.window')

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

-- Public API: Toggle report window
function report.toggle_report()
  if window.is_open("report") then
    window.close("report")
  else
    -- Generate and format report
    local report_data = generator.generate_report()
    local formatted_report = formatter.format_report(report_data)
    
    -- Create report window (read-only)
    window.create({
      id = "report",
      title = "epoch - report",
      width_percent = 0.5,
      height_percent = 0.6,
      filetype = "markdown",
      modifiable = false,
      content = formatted_report
    })
  end
end

return report