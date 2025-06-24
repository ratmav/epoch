-- epoch/storage/serializer/interval_sorter.lua
-- Interval sorting utilities

local interval_sorter = {}

function interval_sorter.copy_intervals(intervals)
  local sorted = {}
  for _, interval in ipairs(intervals) do
    table.insert(sorted, interval)
  end
  return sorted
end

function interval_sorter.compare_intervals(a, b)
  if not a.start then return false end
  if not b.start then return true end
  return a.start < b.start
end

-- Sort intervals in a timesheet by start time
function interval_sorter.sort_intervals(timesheet)
  if not timesheet.intervals or #timesheet.intervals <= 1 then
    return timesheet
  end
  local sorted = interval_sorter.copy_intervals(timesheet.intervals)
  table.sort(sorted, interval_sorter.compare_intervals)
  timesheet.intervals = sorted
  return timesheet
end

return interval_sorter