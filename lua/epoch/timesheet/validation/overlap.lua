-- epoch/timesheet/validation/overlap.lua
-- Validate no overlapping intervals in timesheet

local time_parsing = require('epoch.time.parsing')

local overlap = {}

-- Get stop time value for interval (handles unclosed intervals)
local function get_stop_time_value(interval)
  if interval.stop and interval.stop ~= "" then
    return time_parsing.time_value(interval.stop)
  else
    return 24 * 60  -- Unclosed interval extends to end of day
  end
end

-- Check if two adjacent intervals overlap
local function intervals_overlap(current, next_interval)
  if not current.start or not next_interval.start then
    return false
  end

  local current_stop_value = get_stop_time_value(current)
  local next_start_value = time_parsing.time_value(next_interval.start)

  return next_start_value < current_stop_value
end

-- Sort intervals by start time
local function sort_intervals_by_start(intervals)
  local sorted = vim.deepcopy(intervals)
  table.sort(sorted, function(a, b)
    return time_parsing.time_value(a.start) < time_parsing.time_value(b.start)
  end)
  return sorted
end

-- Get interval description string
local function get_interval_description(interval)
  return string.format("%s/%s/%s", interval.client, interval.project, interval.task)
end

-- Format error message for overlapping intervals
local function format_overlap_error(current, next_interval)
  local current_desc = get_interval_description(current)
  local next_desc = get_interval_description(next_interval)

  if current.stop and current.stop ~= "" then
    return string.format("intervals overlap: '%s' ends at %s but '%s' starts at %s",
                        current_desc, current.stop, next_desc, next_interval.start)
  else
    return string.format("intervals overlap: '%s' has no end time but '%s' starts at %s",
                        current_desc, next_desc, next_interval.start)
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

function overlap.validate(current_timesheet)
  local intervals = current_timesheet.intervals
  if not intervals or #intervals < 2 then
    return true
  end

  local sorted_intervals = sort_intervals_by_start(intervals)
  local has_overlap, error_msg = check_adjacent_pairs(sorted_intervals)
  
  if has_overlap then
    return false, error_msg
  end
  
  return true
end

return overlap