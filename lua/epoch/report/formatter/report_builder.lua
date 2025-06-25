-- epoch/report/formatter/report_builder.lua
-- Report construction and assembly

local week_formatter = require('epoch.report.formatter.week')
local overall = require('epoch.report.formatter.overall')

local report_builder = {}

-- Add period header to report lines
local function add_period_header(lines, report_data)
  if report_data.date_range then
    table.insert(lines, string.format("Period: %s to %s",
      report_data.date_range.first, report_data.date_range.last))
    table.insert(lines, "")
  end
end

-- Add week sections to report lines
local function add_week_sections(lines, weeks)
  for _, week in ipairs(weeks) do
    local week_lines = week_formatter.format_week_section(week)
    for _, line in ipairs(week_lines) do
      table.insert(lines, line)
    end
  end
end

-- Add overall summary sections to report lines
local function add_overall_summaries(lines, report_data)
  -- Overall by week
  local week_summary_lines = overall.format_overall_weeks_section(report_data.weeks, report_data.total_hours)
  for _, line in ipairs(week_summary_lines) do
    table.insert(lines, line)
  end

  -- Overall by client
  local client_summary_lines = overall.format_overall_clients_section(report_data.summary, report_data.total_hours)
  for _, line in ipairs(client_summary_lines) do
    table.insert(lines, line)
  end
end

-- Build report content lines
function report_builder.build_report_lines(report_data)
  local lines = {}
  add_period_header(lines, report_data)
  add_week_sections(lines, report_data.weeks)

  if #report_data.weeks > 0 then
    add_overall_summaries(lines, report_data)
  end

  return lines
end

-- Format report when no weeks data available
function report_builder.format_empty_report(report_data)
  local lines = {}
  add_period_header(lines, report_data)

  local empty_lines = overall.format_overall_clients_section(report_data.summary, report_data.total_hours)
  for _, line in ipairs(empty_lines) do
    table.insert(lines, line)
  end

  return table.concat(lines, "\n")
end

return report_builder