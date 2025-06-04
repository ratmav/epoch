-- epoch/report/formatter.lua
-- Report formatting and display logic

local report_builder = require('epoch.report.formatter.report_builder')

local formatter = {}

function formatter.format_report(report_data)
  if not report_data.weeks or #report_data.weeks == 0 then
    return report_builder.format_empty_report(report_data)
  end

  local lines = report_builder.build_report_lines(report_data)
  return table.concat(lines, "\n")
end

return formatter