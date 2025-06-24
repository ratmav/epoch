-- epoch/commands/validation.lua
-- date validation utilities

local constants = require('epoch.constants')

local validation = {}

function validation.is_valid_date(year, month, day)
  local input_date = {year = year, month = month, day = day}
  local normalized = os.date("*t", os.time(input_date))
  return normalized.year == year and
         normalized.month == month and
         normalized.day == day
end

function validation.parse_date_components(date)
  local year, month, day = date:match("(%d%d%d%d)-(%d%d)-(%d%d)")
  if not year or not month or not day then
    return nil
  end
  return tonumber(year), tonumber(month), tonumber(day)
end

function validation.validate_date_format(date)
  if not date or type(date) ~= "string" then
    return false
  end
  if not date:match(constants.TIMESHEET_DATE_PATTERN_ANCHORED) then
    return false
  end
  local year, month, day = validation.parse_date_components(date)
  return year and validation.is_valid_date(year, month, day)
end

return validation