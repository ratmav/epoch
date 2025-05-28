-- epoch/validation/overlap.lua
-- Interval overlap detection logic

local overlap = {}
local time_utils = require('epoch.validation.time_utils')
local fields = require('epoch.validation.fields')

-- Check if two adjacent intervals overlap
local function intervals_overlap(current, next_interval)
  if not current.start or not next_interval.start then
    return false
  end
  
  -- Get stop time for current interval
  local current_stop_value
  if current.stop and current.stop ~= "" then
    current_stop_value = time_utils.time_value(current.stop)
  else
    -- Unclosed interval extends to end of day
    current_stop_value = 24 * 60
  end
  
  local next_start_value = time_utils.time_value(next_interval.start)
  
  -- Overlap if next starts before current ends
  return next_start_value < current_stop_value
end

-- Sort intervals by start time
local function sort_intervals_by_start(intervals)
  local sorted = {}
  for _, interval in ipairs(intervals) do
    table.insert(sorted, interval)
  end
  
  table.sort(sorted, function(a, b)
    return time_utils.time_value(a.start) < time_utils.time_value(b.start)
  end)
  
  return sorted
end

-- Validate that we have enough intervals to check for overlaps
local function validate_interval_count(intervals)
  return intervals and #intervals >= 2
end

-- Format error message for overlapping intervals
local function format_overlap_error(current, next_interval)
  if current.stop and current.stop ~= "" then
    return string.format(
      "intervals overlap: '%s/%s/%s' ends at %s but '%s/%s/%s' starts at %s",
      current.client, current.project, current.task, current.stop,
      next_interval.client, next_interval.project, next_interval.task, next_interval.start
    )
  else
    return string.format(
      "intervals overlap: '%s/%s/%s' has no end time but '%s/%s/%s' starts at %s",
      current.client, current.project, current.task,
      next_interval.client, next_interval.project, next_interval.task, next_interval.start
    )
  end
end

-- Check adjacent pairs of intervals for overlaps
local function check_adjacent_pairs(sorted_intervals)
  for i = 1, #sorted_intervals - 1 do
    local current = sorted_intervals[i]
    local next_interval = sorted_intervals[i + 1]
    
    if intervals_overlap(current, next_interval) then
      local error_msg = format_overlap_error(current, next_interval)
      return true, error_msg
    end
  end
  return false
end

-- Check for overlapping time intervals using adjacent pairs
function overlap.check_overlapping_intervals(intervals, date)
  if not validate_interval_count(intervals) then
    return false
  end

  local sorted_intervals = sort_intervals_by_start(intervals)
  return check_adjacent_pairs(sorted_intervals)
end

return overlap