-- epoch/report/formatter/overall.lua
-- Overall summary section formatting

local time_utils = require('epoch.time_utils')
local table_formatter = require('epoch.report.formatter.table')

local overall = {}

-- Format overall week summary section
function overall.format_overall_weeks_section(weeks, total_minutes)
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
function overall.format_overall_clients_section(summary, total_minutes)
  local lines = {}

  table.insert(lines, "## Overall By Client")
  table.insert(lines, "")

  local summary_lines = table_formatter.format_summary_table(summary, total_minutes)
  for _, line in ipairs(summary_lines) do
    table.insert(lines, line)
  end

  return lines
end

return overall