-- epoch/report/formatter/table/row_builder.lua
-- Table row building utilities

local row_builder = {}
local time_utils = require('epoch.time')

-- Create table header row
function row_builder.create_table_header(max_client_len, max_project_len, max_task_len)
  return string.format("%-" .. max_client_len .. "s  %-" .. max_project_len .. "s  %-" .. max_task_len .. "s  %s",
    "Client", "Project", "Task", "Hours")
end

-- Create separator line
function row_builder.create_separator_line(max_client_len, max_project_len, max_task_len)
  return string.rep("-", max_client_len) .. "  " ..
         string.rep("-", max_project_len) .. "  " ..
         string.rep("-", max_task_len) .. "  ------"
end

-- Format data rows
function row_builder.format_data_rows(summary, max_client_len, max_project_len, max_task_len, result)
  for _, entry in ipairs(summary) do
    local formatted_time = time_utils.format_duration(entry.minutes)
    local format_str = "%-" .. max_client_len .. "s  %-" .. max_project_len .. "s  %-" .. max_task_len .. "s  %s"
    local row = string.format(format_str, entry.client, entry.project, entry.task, formatted_time)
    table.insert(result, row)
  end
end

-- Format total row if needed
function row_builder.format_total_row(total_mins, max_client_len, max_project_len, max_task_len, separator, result)
  if total_mins and total_mins > 0 then
    table.insert(result, separator)
    local total_formatted = time_utils.format_duration(total_mins)
    local total_format_str = "%-" .. max_client_len .. "s  %-" .. (max_project_len + max_task_len + 2) .. "s  %s"
    local total_row = string.format(total_format_str, "TOTAL", "", total_formatted)
    table.insert(result, total_row)
  end
end

return row_builder