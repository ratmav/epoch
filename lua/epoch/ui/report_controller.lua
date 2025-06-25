-- epoch/ui/report_controller.lua
-- Controls report UI flow and user interactions

local report_controller = {}
local window = require('epoch.ui.window')
local report = require('epoch.report')

-- Handle report window toggling flow
function report_controller.handle_toggle()
  if window.is_open("report") then
    window.close("report")
  else
    report_controller.handle_open()
  end
end

-- Handle report window opening flow
function report_controller.handle_open()
  local report_data = report.generate_report()
  local formatted_content = report.format_report(report_data)
  
  window.create({
    id = "report",
    title = "epoch - report",
    width_percent = 0.5,
    height_percent = 0.6,
    filetype = "markdown",
    modifiable = false,
    content = formatted_content
  })
end

return report_controller