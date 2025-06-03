-- epoch/report/week_utils/date_calculation.lua
-- Date and week calculation utilities

local date_calculation = {}

-- Get week number from date string (YYYY-MM-DD)
function date_calculation.get_week_number(date_str)
  if not date_str or type(date_str) ~= "string" then
    return nil
  end
  
  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
  if not year or not month or not day then
    return nil
  end
  
  -- Validate date ranges
  local y, m, d = tonumber(year), tonumber(month), tonumber(day)
  if m < 1 or m > 12 or d < 1 or d > 31 then
    return nil
  end
  
  local date = os.time({
    year = y,
    month = m,
    day = d
  })
  
  -- Calculate week number (Sunday is first day of week)
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