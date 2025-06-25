-- epoch/report/formatter/overall.lua
-- Overall summary section formatting

local time_utils = require('epoch.time')
local table_formatter = require('epoch.report.formatter.table')

local overall = {}

function overall.create_week_label(week)
  return week.date_range and
    string.format("Week %s", week.date_range.first) or
    string.format("Week %s", week.week)
end

function overall.build_week_rows(weeks)
  local rows = {}
  for _, week in ipairs(weeks) do
    local week_label = overall.create_week_label(week)
    local formatted_hours = string.format("%.3f", week.total_hours)
    table.insert(rows, {week_label, formatted_hours})
  end
  return rows
end

function overall.append_table_lines(lines, table_lines)
  for _, line in ipairs(table_lines) do
    table.insert(lines, line)
  end
end

-- Format overall week summary section
function overall.format_overall_weeks_section(weeks, total_hours)
  local lines = {"## Overall By Week", ""}
  local rows = overall.build_week_rows(weeks)
  local table_lines = table_formatter.format_two_column_table(
    {"Week", "Hours"}, rows, "TOTAL", string.format("%.3f", total_hours))
  overall.append_table_lines(lines, table_lines)
  return lines
end

-- Format overall client summary section
function overall.format_overall_clients_section(summary, total_hours)
  local lines = {}

  table.insert(lines, "## Overall By Client")
  table.insert(lines, "")

  local summary_lines = table_formatter.format_summary_table(summary, total_hours)
  for _, line in ipairs(summary_lines) do
    table.insert(lines, line)
  end

  return lines
end

return overall