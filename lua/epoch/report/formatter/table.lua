-- epoch/report/formatter/table.lua
-- Table formatting utilities

local table_formatter = {}
local column_calculator = require('epoch.report.formatter.table.column_calculator')
local row_builder = require('epoch.report.formatter.table.row_builder')

-- Format a summary table with proper alignment
function table_formatter.format_summary_table(summary, total_mins)
  local result = {}

  if #summary == 0 then
    table.insert(result, "No time entries found for this period.")
    table.insert(result, "")
    return result
  end

  local max_client_len, max_project_len, max_task_len = column_calculator.calculate_column_widths(summary)

  table.insert(result, row_builder.create_table_header(max_client_len, max_project_len, max_task_len))
  local separator = row_builder.create_separator_line(max_client_len, max_project_len, max_task_len)
  table.insert(result, separator)

  row_builder.format_data_rows(summary, max_client_len, max_project_len, max_task_len, result)
  row_builder.format_total_row(total_mins, max_client_len, max_project_len, max_task_len, separator, result)

  table.insert(result, "")
  return result
end

-- Format a simple two-column table
function table_formatter.format_two_column_table(headers, rows, total_label, total_value)
  local result = {}
  local left_header, right_header = headers[1], headers[2]

  -- Calculate column widths
  local left_width = column_calculator.calculate_two_column_width(left_header, rows)
  local right_width = 6 -- "Hours"

  -- Add header
  table.insert(result, string.format("%-" .. left_width .. "s %s", left_header, right_header))
  table.insert(result, string.rep("-", left_width) .. " " .. string.rep("-", right_width))

  -- Add data rows
  for _, row in ipairs(rows) do
    table.insert(result, string.format("%-" .. left_width .. "s %s", row[1], row[2]))
  end

  -- Add total if provided
  if total_label and total_value then
    table.insert(result, string.rep("-", left_width) .. " " .. string.rep("-", right_width))
    table.insert(result, string.format("%-" .. left_width .. "s %s", total_label, total_value))
  end

  table.insert(result, "")
  return result
end

return table_formatter