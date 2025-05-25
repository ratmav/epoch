-- epoch/report/formatter.lua
-- Report formatting and display logic

local formatter = {}
local time_utils = require('epoch.time_utils')
local table_formatter = require('epoch.report.formatter.table')
local week_formatter = require('epoch.report.formatter.week')

-- Format overall week summary section
local function format_overall_weeks_section(weeks, total_minutes)
  local lines = {}
  
  table.insert(lines, "## Overall By Week")
  table.insert(lines, "")
  
  -- Prepare rows for week summary
  local rows = {}
  for _, week in ipairs(weeks) do
    local week_label = week.date_range and 
      string.format("Week %s", week.date_range.first) or 
      string.format("Week %s", week.week)
    local formatted_time = time_utils.format_duration(week.total_minutes)
    table.insert(rows, {week_label, formatted_time})
  end
  
  -- Use table formatter
  local table_lines = table_formatter.format_two_column_table(
    {"Week", "Hours"}, 
    rows,
    "TOTAL", 
    time_utils.format_duration(total_minutes)
  )
  
  for _, line in ipairs(table_lines) do
    table.insert(lines, line)
  end
  
  return lines
end

-- Format overall client summary section
local function format_overall_clients_section(summary, total_minutes)
  local lines = {}
  
  table.insert(lines, "## Overall By Client")
  table.insert(lines, "")
  
  local summary_lines = table_formatter.format_summary_table(summary, total_minutes)
  for _, line in ipairs(summary_lines) do
    table.insert(lines, line)
  end
  
  return lines
end

-- Format the complete report as a string for display
function formatter.format_report(report_data)
  local lines = {}
  
  -- Add period header if available
  if report_data.date_range then
    table.insert(lines, string.format("Period: %s to %s", 
      report_data.date_range.first, report_data.date_range.last))
    table.insert(lines, "")
  end
  
  -- Handle empty data
  if not report_data.weeks or #report_data.weeks == 0 then
    local empty_lines = format_overall_clients_section(report_data.summary, report_data.total_minutes)
    for _, line in ipairs(empty_lines) do
      table.insert(lines, line)
    end
    return table.concat(lines, "\n")
  end
  
  -- Format each week section
  for _, week in ipairs(report_data.weeks) do
    local week_lines = week_formatter.format_week_section(week)
    for _, line in ipairs(week_lines) do
      table.insert(lines, line)
    end
  end
  
  -- Add overall summaries if we have multiple weeks
  if #report_data.weeks > 0 then
    -- Overall by week
    local week_summary_lines = format_overall_weeks_section(report_data.weeks, report_data.total_minutes)
    for _, line in ipairs(week_summary_lines) do
      table.insert(lines, line)
    end
    
    -- Overall by client
    local client_summary_lines = format_overall_clients_section(report_data.summary, report_data.total_minutes)
    for _, line in ipairs(client_summary_lines) do
      table.insert(lines, line)
    end
  end
  
  return table.concat(lines, "\n")
end

return formatter