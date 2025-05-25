-- epoch/report/generator.lua
-- Core report generation logic

local generator = {}
local storage = require('epoch.storage')
local week_utils = require('epoch.report.week_utils')

-- Load all available timesheet dates
function generator.get_all_timesheet_dates()
  local files = storage.get_all_timesheet_files()
  local dates = {}
  
  for _, file_path in ipairs(files) do
    -- Extract date from filename (YYYY-MM-DD.lua)
    local date = vim.fn.fnamemodify(file_path, ":t:r")
    if date:match("^%d%d%d%d%-%d%d%-%d%d$") then
      table.insert(dates, date)
    end
  end
  
  -- Sort dates chronologically
  table.sort(dates)
  
  return dates
end

-- Process intervals from a single timesheet
local function process_timesheet_intervals(timesheet, week_summary, all_summary)
  local day_total = 0
  
  for _, interval in ipairs(timesheet.intervals) do
    -- Skip incomplete intervals
    if interval.client and interval.project and interval.task and interval.start then
      local minutes = week_utils.calculate_interval_minutes(interval, timesheet.date)
      
      -- Update day total
      day_total = day_total + minutes
      
      -- Update week summary
      local key = interval.client .. "|" .. interval.project .. "|" .. interval.task
      if not week_summary[key] then
        week_summary[key] = {
          client = interval.client,
          project = interval.project,
          task = interval.task,
          minutes = 0
        }
      end
      
      week_summary[key].minutes = week_summary[key].minutes + minutes
      
      -- Also update overall summary
      if not all_summary[key] then
        all_summary[key] = {
          client = interval.client,
          project = interval.project,
          task = interval.task,
          minutes = 0
        }
      end
      
      all_summary[key].minutes = all_summary[key].minutes + minutes
    end
  end
  
  return day_total
end

-- Sort summary data by client/project/task
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

-- Process week data and create week summary
local function process_week_data(week, week_data, all_summary)
  local week_summary = {}
  local week_total_minutes = 0
  local daily_totals = {}
  
  -- Sort the timesheet dates in chronological order
  table.sort(week_data.dates)
  
  -- Process each timesheet in this week
  for _, timesheet in ipairs(week_data.timesheets) do
    local day_total = process_timesheet_intervals(timesheet, week_summary, all_summary)
    daily_totals[timesheet.date] = day_total
  end
  
  -- Calculate week total from week summary
  for _, entry in pairs(week_summary) do
    week_total_minutes = week_total_minutes + entry.minutes
  end
  
  -- Convert week summary to sorted array
  local week_summary_array = sort_summary(week_summary)
  
  return {
    week = week,
    dates = week_data.dates,
    summary = week_summary_array,
    total_minutes = week_total_minutes,
    date_range = week_data.date_range,
    daily_totals = daily_totals
  }
end

-- Generate a complete report for all timesheets
function generator.generate_report()
  local all_dates = generator.get_all_timesheet_dates()
  local timesheets = {}
  local timesheets_by_week = {}
  
  -- Load all available timesheets and group by week
  for _, date in ipairs(all_dates) do
    local timesheet = storage.load_timesheet(date)
    if timesheet and timesheet.intervals and #timesheet.intervals > 0 then
      table.insert(timesheets, timesheet)
      
      -- Group by week
      local week = week_utils.get_week_number(date)
      if week then
        if not timesheets_by_week[week] then
          timesheets_by_week[week] = {
            dates = {},
            timesheets = {},
            date_range = week_utils.get_week_date_range(week)
          }
        end
        
        table.insert(timesheets_by_week[week].dates, date)
        table.insert(timesheets_by_week[week].timesheets, timesheet)
      end
    end
  end
  
  -- Return empty report if no timesheets found
  if #timesheets == 0 then
    return {
      timesheets = {},
      summary = {},
      total_minutes = 0,
      dates = all_dates,
      date_range = #all_dates > 0 and {first = all_dates[1], last = all_dates[#all_dates]} or nil,
      weeks = {}
    }
  end
  
  -- Process each week
  local weeks = {}
  local all_summary = {}
  
  for week, week_data in pairs(timesheets_by_week) do
    local week_result = process_week_data(week, week_data, all_summary)
    table.insert(weeks, week_result)
  end
  
  -- Calculate total minutes from all_summary
  local total_minutes = 0
  for _, entry in pairs(all_summary) do
    total_minutes = total_minutes + entry.minutes
  end
  
  -- Sort weeks chronologically, most recent first
  table.sort(weeks, function(a, b)
    return a.week > b.week
  end)
  
  -- Convert all_summary to sorted array
  local summary_array = sort_summary(all_summary)
  
  return {
    timesheets = timesheets,
    summary = summary_array,
    total_minutes = total_minutes,
    dates = all_dates,
    date_range = #all_dates > 0 and {first = all_dates[1], last = all_dates[#all_dates]} or nil,
    weeks = weeks
  }
end

return generator