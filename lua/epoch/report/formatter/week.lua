-- epoch/report/formatter/week.lua
-- Week section formatting

local week_formatter = {}
local table_formatter = require('epoch.report.formatter.table')
local daily_formatter = require('epoch.report.formatter.daily')

-- Format a single week section
function week_formatter.format_week_section(week_data)
  local lines = {}

  -- Week header
  if week_data.date_range then
    table.insert(lines, string.format("## Week of %s to %s",
      week_data.date_range.first, week_data.date_range.last))
  else
    table.insert(lines, string.format("## Week %s", week_data.week))
  end
  table.insert(lines, "")

  -- Daily totals section
  if week_data.daily_totals and week_data.dates and #week_data.dates > 0 then
    local daily_lines = daily_formatter.format_daily_section(
      week_data.daily_totals,
      week_data.dates,
      week_data.total_minutes
    )
    for _, line in ipairs(daily_lines) do
      table.insert(lines, line)
    end
  end

  -- Week summary by client/project/task
  table.insert(lines, "### By Client")
  table.insert(lines, "")

  local summary_lines = table_formatter.format_summary_table(
    week_data.summary,
    week_data.total_minutes
  )
  for _, line in ipairs(summary_lines) do
    table.insert(lines, line)
  end

  table.insert(lines, "")

  return lines
end

return week_formatter