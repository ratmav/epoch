-- epoch/report/week_utils/interval_calculation.lua
-- Interval hours reading utilities

local interval_calculation = {}

-- Get hours from completed interval
function interval_calculation.get_interval_hours(interval)
  return interval.hours or 0
end

return interval_calculation