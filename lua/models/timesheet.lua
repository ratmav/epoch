-- models/timesheet.lua
-- Domain model for daily timesheets

local timesheet = {}
local interval_model = require('models.interval')
local time_service = require('services.time')

-- Create a new timesheet for a date
function timesheet.create(date)
  date = date or os.date("%Y-%m-%d")
  
  return {
    date = date,
    intervals = {},
    daily_total = "00:00"
  }
end

-- Calculate daily total from all completed intervals
local function calculate_daily_total(timesheet_obj)
  local total_minutes = 0
  
  for _, interval in ipairs(timesheet_obj.intervals) do
    if interval_model.is_complete(interval) then
      total_minutes = total_minutes + interval_model.calculate_duration_minutes(interval)
    end
  end
  
  return time_service.format_duration(total_minutes)
end

-- Update timesheet's daily total
local function update_daily_total(timesheet_obj)
  timesheet_obj.daily_total = calculate_daily_total(timesheet_obj)
end

-- Add interval to timesheet and update totals
function timesheet.add_interval(timesheet_obj, interval)
  table.insert(timesheet_obj.intervals, interval)
  update_daily_total(timesheet_obj)
end

-- Close the most recent open interval in timesheet
function timesheet.close_current_interval(timesheet_obj, stop_time)
  if #timesheet_obj.intervals == 0 then
    return false
  end
  
  local last_interval = timesheet_obj.intervals[#timesheet_obj.intervals]
  
  if interval_model.is_open(last_interval) then
    local success = interval_model.close(last_interval, stop_time)
    if success then
      update_daily_total(timesheet_obj)
    end
    return success
  end
  
  return false
end

-- Check if timesheet has any open intervals
function timesheet.has_open_interval(timesheet_obj)
  for _, interval in ipairs(timesheet_obj.intervals) do
    if interval_model.is_open(interval) then
      return true
    end
  end
  return false
end

-- Calculate daily total (exposed for external use)
function timesheet.calculate_daily_total(timesheet_obj)
  return calculate_daily_total(timesheet_obj)
end

-- Get only completed intervals from timesheet
function timesheet.get_completed_intervals(timesheet_obj)
  local completed = {}
  
  for _, interval in ipairs(timesheet_obj.intervals) do
    if interval_model.is_complete(interval) then
      table.insert(completed, interval)
    end
  end
  
  return completed
end

-- Validate timesheet structure and content
function timesheet.validate(timesheet_obj)
  if not timesheet_obj then
    return false, "Timesheet cannot be nil"
  end
  
  if not timesheet_obj.date then
    return false, "Timesheet must have a date"
  end
  
  if not timesheet_obj.intervals then
    return false, "Timesheet must have intervals array"
  end
  
  if type(timesheet_obj.intervals) ~= "table" then
    return false, "Intervals must be a table"
  end
  
  -- Validate each interval has required structure
  for i, interval in ipairs(timesheet_obj.intervals) do
    if not interval.client or not interval.project or not interval.task or not interval.start then
      return false, string.format("Interval %d is missing required fields", i)
    end
    
    if not interval.notes then
      return false, string.format("Interval %d is missing notes field", i)
    end
  end
  
  return true
end

return timesheet