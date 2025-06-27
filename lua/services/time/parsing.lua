-- services/time/parsing.lua
-- Time and date parsing utilities

local parsing = {}

-- Parse time string components
function parsing.parse_time_components(time_str)
  if not time_str or time_str == "" then
    return nil
  end

  local hour, minute, period = time_str:match("^(%d+):(%d+)%s*([AP]M)$")
  if not hour or not minute or not period then
    return nil
  end

  return tonumber(hour), tonumber(minute), period
end

-- Validate time component ranges
function parsing.validate_time_ranges(hour, minute)
  return hour >= 1 and hour <= 12 and minute >= 0 and minute <= 59
end

-- Parse date components from YYYY-MM-DD format
function parsing.parse_date_components(date_str)
  if not date_str then return nil end

  local year, month, day = date_str:match("^(%d+)-(%d+)-(%d+)$")
  if not year or not month or not day then
    return nil
  end
  return tonumber(year), tonumber(month), tonumber(day)
end

return parsing
