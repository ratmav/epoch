-- epoch/report/formatter/daily.lua
-- Daily totals formatting

local daily_formatter = {}
local time_utils = require('epoch.time')
local table_formatter = require('epoch.report.formatter.table')

function daily_formatter.handle_empty_data(result)
  table.insert(result, "No daily totals available.")
  table.insert(result, "")
  return result
end

function daily_formatter.sort_dates_chronologically(daily_totals)
  local sorted_dates = {}
  for date, _ in pairs(daily_totals) do
    table.insert(sorted_dates, date)
  end
  table.sort(sorted_dates)
  return sorted_dates
end

function daily_formatter.build_date_rows(daily_totals, sorted_dates)
  local rows = {}
  for _, date in ipairs(sorted_dates) do
    local minutes = daily_totals[date] or 0
    local formatted_time = time_utils.format_duration(minutes)
    table.insert(rows, {date, formatted_time})
  end
  return rows
end

function daily_formatter.append_table_to_result(result, table_lines)
  for _, line in ipairs(table_lines) do
    table.insert(result, line)
  end
end

-- Format daily totals for a week
function daily_formatter.format_daily_section(daily_totals, dates, week_total_minutes)
  local result = {}
  if not daily_totals or not dates or #dates == 0 then
    return daily_formatter.handle_empty_data(result)
  end
  table.insert(result, "### By Day")
  table.insert(result, "")
  local sorted_dates = daily_formatter.sort_dates_chronologically(daily_totals)
  local rows = daily_formatter.build_date_rows(daily_totals, sorted_dates)
  local table_lines = table_formatter.format_two_column_table(
    {"Date", "Hours"}, rows, "TOTAL", time_utils.format_duration(week_total_minutes))
  daily_formatter.append_table_to_result(result, table_lines)
  return result
end

return daily_formatter