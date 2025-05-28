-- epoch/report/formatter/table.lua
-- Table formatting utilities

local table_formatter = {}
local time_utils = require('epoch.time_utils')

-- Calculate column widths based on data
local function calculate_column_widths(summary)
  local max_client_len = 6  -- "Client"
  local max_project_len = 7 -- "Project"
  local max_task_len = 4    -- "Task"
  
  for _, entry in ipairs(summary) do
    max_client_len = math.max(max_client_len, #entry.client)
    max_project_len = math.max(max_project_len, #entry.project)
    max_task_len = math.max(max_task_len, #entry.task)
  end
  
  return max_client_len, max_project_len, max_task_len
end

-- Create table header row
local function create_table_header(max_client_len, max_project_len, max_task_len)
  return string.format("%-" .. max_client_len .. "s  %-" .. max_project_len .. "s  %-" .. max_task_len .. "s  %s",
    "Client", "Project", "Task", "Hours")
end

-- Create separator line
local function create_separator_line(max_client_len, max_project_len, max_task_len)
  return string.rep("-", max_client_len) .. "  " ..
         string.rep("-", max_project_len) .. "  " ..
         string.rep("-", max_task_len) .. "  ------"
end

-- Format data rows
local function format_data_rows(summary, max_client_len, max_project_len, max_task_len, result)
  for _, entry in ipairs(summary) do
    local formatted_time = time_utils.format_duration(entry.minutes)
    local row = string.format("%-" .. max_client_len .. "s  %-" .. max_project_len .. "s  %-" .. max_task_len .. "s  %s",
      entry.client, entry.project, entry.task, formatted_time)
    table.insert(result, row)
  end
end

-- Format total row if needed
local function format_total_row(total_mins, max_client_len, max_project_len, max_task_len, separator, result)
  if total_mins and total_mins > 0 then
    table.insert(result, separator)
    local total_formatted = time_utils.format_duration(total_mins)
    local total_row = string.format("%-" .. max_client_len .. "s  %-" .. (max_project_len + max_task_len + 2) .. "s  %s",
      "TOTAL", "", total_formatted)
    table.insert(result, total_row)
  end
end

-- Format a summary table with proper alignment
function table_formatter.format_summary_table(summary, total_mins)
  local result = {}
  
  if #summary == 0 then
    table.insert(result, "No time entries found for this period.")
    table.insert(result, "")
    return result
  end
  
  local max_client_len, max_project_len, max_task_len = calculate_column_widths(summary)
  
  table.insert(result, create_table_header(max_client_len, max_project_len, max_task_len))
  local separator = create_separator_line(max_client_len, max_project_len, max_task_len)
  table.insert(result, separator)
  
  format_data_rows(summary, max_client_len, max_project_len, max_task_len, result)
  format_total_row(total_mins, max_client_len, max_project_len, max_task_len, separator, result)
  
  table.insert(result, "")
  return result
end

-- Format a simple two-column table
function table_formatter.format_two_column_table(headers, rows, total_label, total_value)
  local result = {}
  local left_header, right_header = headers[1], headers[2]
  
  -- Calculate column widths
  local left_width = math.max(#left_header, 12)
  local right_width = 6 -- "Hours"
  
  for _, row in ipairs(rows) do
    left_width = math.max(left_width, #row[1])
  end
  
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