-- epoch/validation/overlap/init.lua
-- Overlap validation interface - delegates to specialized modules
-- coverage: no tests

local overlap = {}
local multiple_open = require('epoch.validation.overlap.multiple_open')
local adjacent_pairs = require('epoch.validation.overlap.adjacent_pairs')

-- Public API: Check for multiple open intervals (only one allowed)
function overlap.check_multiple_open_intervals(intervals)
  return multiple_open.check(intervals)
end

-- Public API: Check for overlapping time intervals using adjacent pairs
function overlap.check_overlapping_intervals(intervals)
  return adjacent_pairs.check(intervals)
end

return overlap