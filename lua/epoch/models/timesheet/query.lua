-- models/timesheet/query.lua
-- Timesheet query operations

local query = {}
local interval_model = require('epoch.models.interval')

-- Check if timesheet has any open intervals
function query.has_open_interval(this_timesheet)
  for _, interval in ipairs(this_timesheet.intervals) do
    if interval_model.is_open(interval) then
      return true
    end
  end
  return false
end

-- Get only completed intervals from timesheet
function query.get_completed_intervals(this_timesheet)
  local completed = {}

  for _, interval in ipairs(this_timesheet.intervals) do
    if interval_model.is_complete(interval) then
      table.insert(completed, interval)
    end
  end

  return completed
end

-- Get timesheets within date range (collection operation)
function query.get_by_date_range(timesheets, start_date, end_date)
  if not start_date or not end_date then
    return timesheets
  end

  local filtered = {}
  for _, this_timesheet in ipairs(timesheets) do
    if this_timesheet.date >= start_date and this_timesheet.date <= end_date then
      table.insert(filtered, this_timesheet)
    end
  end

  return filtered
end

-- Private: get week number for date
local function get_week_number(date)
  local year, month, day = date:match("(%d+)-(%d+)-(%d+)")
  if not year then return nil end
  return os.date("%U", os.time({year=tonumber(year), month=tonumber(month), day=tonumber(day)}))
end

-- Private: build week map from timesheets
local function build_week_map(timesheets)
  local week_map = {}
  for _, this_timesheet in ipairs(timesheets) do
    local week_num = get_week_number(this_timesheet.date)
    if week_num then
      if not week_map[week_num] then
        week_map[week_num] = {week_number = week_num, timesheets = {}, total_minutes = 0}
      end
      table.insert(week_map[week_num].timesheets, this_timesheet)
    end
  end
  return week_map
end

-- Private: convert week map to array
local function week_map_to_array(week_map)
  local weeks = {}
  for _, week_data in pairs(week_map) do
    table.insert(weeks, week_data)
  end
  return weeks
end

-- Group timesheets by week (collection operation)
function query.group_by_week(timesheets)
  local week_map = build_week_map(timesheets)
  return week_map_to_array(week_map)
end

return query
