-- epoch/report/generator/summary_utils.lua
-- Summary sorting and organization utilities

local summary_utils = {}

local function dict_to_array(summary_dict)
  local summary_array = {}
  for _, entry in pairs(summary_dict) do
    table.insert(summary_array, entry)
  end
  return summary_array
end

local function compare_entries(a, b)
  if a.client ~= b.client then
    return a.client < b.client
  elseif a.project ~= b.project then
    return a.project < b.project
  else
    return a.task < b.task
  end
end

-- Sort summary data by client/project/task
function summary_utils.sort_summary(summary_dict)
  local summary_array = dict_to_array(summary_dict)
  table.sort(summary_array, compare_entries)
  return summary_array
end

-- Calculate total hours from summary dictionary
function summary_utils.calculate_total_hours(summary_dict)
  local total_hours = 0
  for _, entry in pairs(summary_dict) do
    total_hours = total_hours + entry.hours
  end
  return total_hours
end

return summary_utils