-- epoch/report/formatter/table/column_calculator.lua
-- Column width calculation utilities

local column_calculator = {}

-- Calculate column widths based on data
function column_calculator.calculate_column_widths(summary)
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

-- Calculate two-column width
function column_calculator.calculate_two_column_width(header, rows)
  local left_width = math.max(#header, 12)

  for _, row in ipairs(rows) do
    left_width = math.max(left_width, #row[1])
  end

  return left_width
end

return column_calculator