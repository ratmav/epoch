-- epoch/validation/overlap/multiple_open.lua
-- Multiple open intervals validation logic

local multiple_open = {}

-- Get interval description string
local function get_interval_description(interval)
  return string.format("%s/%s/%s", interval.client, interval.project, interval.task)
end

-- Collect all open intervals from interval list
local function collect_open_intervals(intervals)
  local open_intervals = {}
  for _, interval in ipairs(intervals) do
    if not interval.stop or interval.stop == "" then
      table.insert(open_intervals, interval)
    end
  end
  return open_intervals
end

-- Format error message for multiple open intervals
local function format_multiple_open_error(open_intervals)
  local first = open_intervals[1]
  local second = open_intervals[2]
  local first_desc = get_interval_description(first)
  local second_desc = get_interval_description(second)
  return string.format("multiple open intervals: '%s' and '%s' are both unclosed",
                      first_desc, second_desc)
end

-- Check for multiple open intervals (only one allowed)
function multiple_open.check(intervals)
  if not intervals or #intervals == 0 then
    return false
  end

  local open_intervals = collect_open_intervals(intervals)
  if #open_intervals > 1 then
    local error_msg = format_multiple_open_error(open_intervals)
    return true, error_msg
  end

  return false
end

return multiple_open
