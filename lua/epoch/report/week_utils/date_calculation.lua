-- epoch/report/week_utils/date_calculation.lua
-- Date and week calculation utilities

local date_calculation = {}

-- Parse and validate date string components
local function parse_date_string(date_str)
  if not date_str or type(date_str) ~= "string" then
    return nil
  end

  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
  if not year or not month or not day then
    return nil
  end

  return tonumber(year), tonumber(month), tonumber(day)
end

-- Validate date component ranges
local function validate_date_components(month, day)
  return month >= 1 and month <= 12 and day >= 1 and day <= 31
end

-- Get week number from date string (YYYY-MM-DD)
function date_calculation.get_week_number(date_str)
  local year, month, day = parse_date_string(date_str)
  if not year then
    return nil
  end

  if not validate_date_components(month, day) then
    return nil
  end

  local date = os.time({year = year, month = month, day = day})
  return os.date("%Y-%U", date)
end

-- Parse week string format (YYYY-WW)
function date_calculation.parse_week_string(week_str)
  if not week_str or type(week_str) ~= "string" then
    return nil
  end

  local year, week = week_str:match("(%d+)-(%d+)")
  if not year or not week then
    return nil
  end
  return tonumber(year), tonumber(week)
end

return date_calculation