-- epoch/report/formatter/daily.lua
-- Daily totals formatting

local daily_formatter = {}
local time_utils = require('epoch.time_utils')
local table_formatter = require('epoch.report.formatter.table')

-- Format daily totals for a week
function daily_formatter.format_daily_section(daily_totals, dates, week_total_minutes)
  local result = {}

  if not daily_totals or not dates or #dates == 0 then
    table.insert(result, "No daily totals available.")
    table.insert(result, "")
    return result
  end

  table.insert(result, "### By Day")
  table.insert(result, "")

  -- Sort dates chronologically
  local sorted_dates = {}
  for date, _ in pairs(daily_totals) do
    table.insert(sorted_dates, date)
  end
  table.sort(sorted_dates)

  -- Prepare rows for table formatter
  local rows = {}
  for _, date in ipairs(sorted_dates) do
    local minutes = daily_totals[date] or 0
    local formatted_time = time_utils.format_duration(minutes)
    table.insert(rows, {date, formatted_time})
  end

  -- Use table formatter for consistent formatting
  local table_lines = table_formatter.format_two_column_table(
    {"Date", "Hours"},
    rows,
    "TOTAL",
    time_utils.format_duration(week_total_minutes)
  )

  for _, line in ipairs(table_lines) do
    table.insert(result, line)
  end

  return result
end

return daily_formatter