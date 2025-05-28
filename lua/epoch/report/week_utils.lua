-- epoch/report/week_utils.lua
-- Week calculation utilities for report generation

local week_utils = {}
local time_utils = require('epoch.time_utils')

-- Get week number from date string (YYYY-MM-DD)
function week_utils.get_week_number(date_str)
  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
  if not year or not month or not day then
    return nil
  end
  
  local date = os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day)
  })
  
  -- Calculate week number (Sunday is first day of week)
  return os.date("%Y-%U", date)
end

-- Parse week string format (YYYY-WW)
local function parse_week_string(week_str)
  local year, week = week_str:match("(%d+)-(%d+)")
  if not year or not week then
    return nil
  end
  return tonumber(year), tonumber(week)
end

-- Calculate timestamp for January 1st of given year
local function calculate_year_start(year)
  return os.time({
    year = year,
    month = 1,
    day = 1,
    hour = 0,
    min = 0,
    sec = 0
  })
end

-- Calculate week start timestamp with weekday adjustments
local function calculate_week_start(year_start, week_num)
  local jan1_wday = tonumber(os.date("%w", year_start))
  local week_start = year_start + (week_num * 7 * 86400)
  
  if jan1_wday > 0 then
    week_start = week_start - (jan1_wday * 86400)
  end
  
  return week_start
end

-- Create date range object from week start timestamp
local function create_date_range(week_start)
  local week_end = week_start + (6 * 86400)
  return {
    first = os.date("%Y-%m-%d", week_start),
    last = os.date("%Y-%m-%d", week_end)
  }
end

-- Get week date range from week number string (YYYY-WW)
function week_utils.get_week_date_range(week_str)
  local year, week_num = parse_week_string(week_str)
  if not year then return nil end
  
  local year_start = calculate_year_start(year)
  local week_start = calculate_week_start(year_start, week_num)
  
  return create_date_range(week_start)
end

-- Calculate minutes between two time strings on the same day
function week_utils.calculate_interval_minutes(interval, date)
  -- Skip unclosed intervals
  if not interval.stop or interval.stop == "" then
    return 0
  end
  
  local start_time = time_utils.time_to_seconds(interval.start, date)
  local stop_time = time_utils.time_to_seconds(interval.stop, date)
  
  if not start_time or not stop_time then
    return 0
  end
  
  -- Calculate minutes
  local diff_seconds = stop_time - start_time
  return math.max(0, math.floor(diff_seconds / 60))
end

return week_utils