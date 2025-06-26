-- models/report.lua
-- Domain model for time tracking reports

local report = {}
local timesheet_model = require('models.timesheet')
local interval_model = require('models.interval')
local time_service = require('services.time')

-- Create a new empty report
function report.create()
  return {
    timesheets = {},
    summary = {},
    total_minutes = 0,
    dates = {},
    date_range = nil,
    weeks = {}
  }
end

-- Update date range when adding timesheets
local function update_date_range(report_obj)
  if #report_obj.dates == 0 then
    report_obj.date_range = nil
    return
  end
  
  local sorted_dates = {}
  for _, date in ipairs(report_obj.dates) do
    table.insert(sorted_dates, date)
  end
  table.sort(sorted_dates)
  
  report_obj.date_range = {
    first = sorted_dates[1],
    last = sorted_dates[#sorted_dates]
  }
end

-- Add timesheet to report and update totals
function report.add_timesheet(report_obj, timesheet_obj)
  table.insert(report_obj.timesheets, timesheet_obj)
  table.insert(report_obj.dates, timesheet_obj.date)
  
  -- Add minutes from completed intervals
  local completed_intervals = timesheet_model.get_completed_intervals(timesheet_obj)
  for _, interval_obj in ipairs(completed_intervals) do
    report_obj.total_minutes = report_obj.total_minutes + interval_model.calculate_duration_minutes(interval_obj)
  end
  
  update_date_range(report_obj)
end

-- Create summary key for grouping intervals
local function create_summary_key(interval_obj)
  return interval_obj.client .. "|" .. interval_obj.project .. "|" .. interval_obj.task
end

-- Create summary entry for an interval
local function create_summary_entry(interval_obj)
  return {
    client = interval_obj.client,
    project = interval_obj.project,
    task = interval_obj.task,
    minutes = 0
  }
end

-- Sort summary entries by client, project, task
local function sort_summary(summary_dict)
  local summary_array = {}
  for _, entry in pairs(summary_dict) do
    table.insert(summary_array, entry)
  end
  
  table.sort(summary_array, function(a, b)
    if a.client ~= b.client then
      return a.client < b.client
    elseif a.project ~= b.project then
      return a.project < b.project
    else
      return a.task < b.task
    end
  end)
  
  return summary_array
end

-- Calculate summary by aggregating intervals across timesheets
function report.calculate_summary(report_obj)
  local summary_dict = {}
  
  for _, timesheet_obj in ipairs(report_obj.timesheets) do
    local completed_intervals = timesheet_model.get_completed_intervals(timesheet_obj)
    
    for _, interval_obj in ipairs(completed_intervals) do
      local key = create_summary_key(interval_obj)
      
      if not summary_dict[key] then
        summary_dict[key] = create_summary_entry(interval_obj)
      end
      
      summary_dict[key].minutes = summary_dict[key].minutes + interval_model.calculate_duration_minutes(interval_obj)
    end
  end
  
  report_obj.summary = sort_summary(summary_dict)
end

-- Get timesheets within date range (inclusive)
function report.get_timesheets_by_date_range(report_obj, start_date, end_date)
  if not start_date or not end_date then
    return report_obj.timesheets
  end
  
  local filtered = {}
  for _, timesheet_obj in ipairs(report_obj.timesheets) do
    if timesheet_obj.date >= start_date and timesheet_obj.date <= end_date then
      table.insert(filtered, timesheet_obj)
    end
  end
  
  return filtered
end

-- Calculate total minutes from all completed intervals
function report.calculate_total_minutes(report_obj)
  local total = 0
  
  for _, timesheet_obj in ipairs(report_obj.timesheets) do
    local completed_intervals = timesheet_model.get_completed_intervals(timesheet_obj)
    
    for _, interval_obj in ipairs(completed_intervals) do
      total = total + interval_model.calculate_duration_minutes(interval_obj)
    end
  end
  
  return total
end

-- Get week number from date string (simplified - assumes YYYY-MM-DD format)
local function get_week_number(date_str)
  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
  if not year then return nil end
  
  local timestamp = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day)})
  local week_num = os.date("%W", timestamp)
  
  return year .. "-" .. string.format("%02d", week_num)
end

-- Group timesheets by week and calculate weekly totals
function report.group_by_week(report_obj)
  local weeks_dict = {}
  
  for _, timesheet_obj in ipairs(report_obj.timesheets) do
    local week_num = get_week_number(timesheet_obj.date)
    if week_num then
      if not weeks_dict[week_num] then
        weeks_dict[week_num] = {
          week = week_num,
          timesheets = {},
          total_minutes = 0
        }
      end
      
      table.insert(weeks_dict[week_num].timesheets, timesheet_obj)
      
      -- Add minutes from completed intervals
      local completed_intervals = timesheet_model.get_completed_intervals(timesheet_obj)
      for _, interval_obj in ipairs(completed_intervals) do
        weeks_dict[week_num].total_minutes = weeks_dict[week_num].total_minutes + interval_model.calculate_duration_minutes(interval_obj)
      end
    end
  end
  
  -- Convert to array and sort by week number
  local weeks_array = {}
  for _, week_data in pairs(weeks_dict) do
    table.insert(weeks_array, week_data)
  end
  
  table.sort(weeks_array, function(a, b)
    return a.week > b.week  -- Most recent first
  end)
  
  report_obj.weeks = weeks_array
end

-- Validate report structure and content
function report.validate(report_obj)
  if not report_obj then
    return false, "Report cannot be nil"
  end
  
  if not report_obj.timesheets then
    return false, "Report must have timesheets array"
  end
  
  if not report_obj.summary then
    return false, "Report must have summary array"
  end
  
  if not report_obj.total_minutes then
    return false, "Report must have total_minutes field"
  end
  
  if not report_obj.dates then
    return false, "Report must have dates array"
  end
  
  if not report_obj.weeks then
    return false, "Report must have weeks array"
  end
  
  -- Validate each timesheet
  for i, timesheet_obj in ipairs(report_obj.timesheets) do
    local is_valid, error_msg = timesheet_model.validate(timesheet_obj)
    if not is_valid then
      return false, string.format("Timesheet %d is invalid: %s", i, error_msg)
    end
  end
  
  return true
end

return report