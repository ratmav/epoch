-- epoch/report/generator.lua
-- Core report generation logic

local generator = {}
local data_loader = require('epoch.report.generator.data_loader')
local week_processor = require('epoch.report.generator.processor.week')
local summary_utils = require('epoch.report.generator.summary_utils')

-- Load all available timesheet dates
function generator.get_all_timesheet_dates()
  return data_loader.get_all_timesheet_dates()
end

-- Generate a complete report for all timesheets
function generator.generate_report()
  local all_dates = data_loader.get_all_timesheet_dates()
  local timesheets = data_loader.load_timesheets(all_dates)
  
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
  
  -- Group timesheets by week and process
  local timesheets_by_week = week_processor.group_timesheets_by_week(timesheets)
  local weeks = {}
  local all_summary = {}
  
  for week_num, week_data in pairs(timesheets_by_week) do
    local week_result = week_processor.process_week_data(week_num, week_data, all_summary)
    table.insert(weeks, week_result)
  end
  
  -- Sort weeks chronologically, most recent first
  table.sort(weeks, function(a, b)
    return a.week > b.week
  end)
  
  -- Calculate totals and convert summary
  local total_minutes = summary_utils.calculate_total_minutes(all_summary)
  local summary_array = summary_utils.sort_summary(all_summary)
  
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