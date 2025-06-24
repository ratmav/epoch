-- epoch/timesheet/validation/open_intervals.lua
-- Validate only one open interval at a time in timesheet

local open_intervals = {}

-- Get interval description string
local function get_interval_description(interval)
  return string.format("%s/%s/%s", interval.client, interval.project, interval.task)
end

-- Collect all open intervals from interval list
local function collect_open_intervals(intervals)
  local open_intervals_list = {}
  for _, interval in ipairs(intervals) do
    if not interval.stop or interval.stop == "" then
      table.insert(open_intervals_list, interval)
    end
  end
  return open_intervals_list
end

-- Format error message for multiple open intervals
local function format_multiple_open_error(open_intervals_list)
  local first = open_intervals_list[1]
  local second = open_intervals_list[2]
  local first_desc = get_interval_description(first)
  local second_desc = get_interval_description(second)
  return string.format("multiple open intervals: '%s' and '%s' are both unclosed",
                      first_desc, second_desc)
end

function open_intervals.validate(current_timesheet)
  local intervals = current_timesheet.intervals
  if not intervals or #intervals == 0 then
    return true
  end

  local open_intervals_list = collect_open_intervals(intervals)
  if #open_intervals_list > 1 then
    local error_msg = format_multiple_open_error(open_intervals_list)
    return false, error_msg
  end

  return true
end

return open_intervals