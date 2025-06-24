-- epoch/report/formatter/table.lua
-- Table formatting utilities

local table_formatter = {}
local column_calculator = require('epoch.report.formatter.table.column_calculator')
local row_builder = require('epoch.report.formatter.table.row_builder')

function table_formatter.handle_empty_summary(result)
  table.insert(result, "No time entries found for this period.")
  table.insert(result, "")
  return result
end

function table_formatter.build_table_structure(summary, total_mins, result)
  local max_client_len, max_project_len, max_task_len = column_calculator.calculate_column_widths(summary)
  table.insert(result, row_builder.create_table_header(max_client_len, max_project_len, max_task_len))
  local separator = row_builder.create_separator_line(max_client_len, max_project_len, max_task_len)
  table.insert(result, separator)
  row_builder.format_data_rows(summary, max_client_len, max_project_len, max_task_len, result)
  row_builder.format_total_row(total_mins, max_client_len, max_project_len, max_task_len, separator, result)
  table.insert(result, "")
end

-- Format a summary table with proper alignment
function table_formatter.format_summary_table(summary, total_mins)
  local result = {}
  if #summary == 0 then
    return table_formatter.handle_empty_summary(result)
  end
  table_formatter.build_table_structure(summary, total_mins, result)
  return result
end

function table_formatter.add_two_column_header(result, left_header, right_header, left_width, right_width)
  table.insert(result, string.format("%-" .. left_width .. "s %s", left_header, right_header))
  table.insert(result, string.rep("-", left_width) .. " " .. string.rep("-", right_width))
end

function table_formatter.add_two_column_rows(result, rows, left_width)
  for _, row in ipairs(rows) do
    table.insert(result, string.format("%-" .. left_width .. "s %s", row[1], row[2]))
  end
end

function table_formatter.add_two_column_total(result, total_label, total_value, left_width, right_width)
  if total_label and total_value then
    table.insert(result, string.rep("-", left_width) .. " " .. string.rep("-", right_width))
    table.insert(result, string.format("%-" .. left_width .. "s %s", total_label, total_value))
  end
end

-- Format a simple two-column table
function table_formatter.format_two_column_table(headers, rows, total_label, total_value)
  local result = {}
  local left_header, right_header = headers[1], headers[2]
  local left_width = column_calculator.calculate_two_column_width(left_header, rows)
  local right_width = 6 -- "Hours"

  table_formatter.add_two_column_header(result, left_header, right_header, left_width, right_width)
  table_formatter.add_two_column_rows(result, rows, left_width)
  table_formatter.add_two_column_total(result, total_label, total_value, left_width, right_width)
  table.insert(result, "")
  return result
end

return table_formatter
