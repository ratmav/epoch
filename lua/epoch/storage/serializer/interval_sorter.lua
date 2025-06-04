-- epoch/storage/serializer/interval_sorter.lua
-- Interval sorting utilities

local interval_sorter = {}

-- Sort intervals in a timesheet by start time
function interval_sorter.sort_intervals(timesheet)
  if not timesheet.intervals or #timesheet.intervals <= 1 then
    return timesheet
  end

  local sorted = {}
  for _, interval in ipairs(timesheet.intervals) do
    table.insert(sorted, interval)
  end

  table.sort(sorted, function(a, b)
    if not a.start then return false end
    if not b.start then return true end
    return a.start < b.start
  end)

  timesheet.intervals = sorted
  return timesheet
end

return interval_sorter