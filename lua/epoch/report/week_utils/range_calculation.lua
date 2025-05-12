-- epoch/report/week_utils/range_calculation.lua
-- Week range calculation utilities

local range_calculation = {}
local date_calculation = require('epoch.report.week_utils.date_calculation')

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
function range_calculation.get_week_date_range(week_str)
  local year, week_num = date_calculation.parse_week_string(week_str)
  if not year then return nil end

  local year_start = calculate_year_start(year)
  local week_start = calculate_week_start(year_start, week_num)

  return create_date_range(week_start)
end

return range_calculation