-- epoch/ui/interval.lua
-- Interval operations - main module
-- coverage: no tests

local creation = require('epoch.ui.interval.creation')
local calculation = require('epoch.ui.interval.calculation')
local timing = require('epoch.ui.interval.timing')

local interval = {}

-- Re-export creation functions
interval.create = creation.create
interval.close_current = creation.close_current

-- Add a new interval to the timesheet
-- If there's an unclosed interval, it will be closed first
-- Returns: updated timesheet
function interval.add_to_timesheet(timesheet, new_interval)
  local updated = vim.deepcopy(timesheet)
  interval.close_current(updated)
  table.insert(updated.intervals, new_interval)
  return updated
end

-- Re-export calculation functions
interval.calculate_daily_total = calculation.calculate_daily_total

-- Re-export timing functions
interval.resolve_timing = timing.resolve_timing

return interval