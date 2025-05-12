-- epoch/report/ui.lua
-- Report UI window management

local ui = {}
local generator = require('epoch.report.generator')
local formatter = require('epoch.report.formatter')
local window = require('epoch.ui.window')

-- Generate formatted report content
local function generate_formatted_report()
  local report_data = generator.generate_report()
  return formatter.format_report(report_data)
end

-- Create report window with content
local function create_report_window(content)
  window.create({
    id = "report",
    title = "epoch - report",
    width_percent = 0.5,
    height_percent = 0.6,
    filetype = "markdown",
    modifiable = false,
    content = content
  })
end

-- Toggle report window visibility
function ui.toggle_report()
  if window.is_open("report") then
    window.close("report")
  else
    local formatted_report = generate_formatted_report()
    create_report_window(formatted_report)
  end
end

return ui