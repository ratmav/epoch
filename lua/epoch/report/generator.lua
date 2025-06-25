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

-- Create empty report structure when no timesheets exist
local function create_empty_report(all_dates)
  return {
    timesheets = {},
    summary = {},
    total_hours = 0,
    dates = all_dates,
    date_range = #all_dates > 0 and {first = all_dates[1], last = all_dates[#all_dates]} or nil,
    weeks = {}
  }
end

-- Process all weeks
local function process_weeks(timesheets_by_week, all_summary)
  local weeks = {}
  for week_num, week_data in pairs(timesheets_by_week) do
    local week_result = week_processor.process_week_data(week_num, week_data, all_summary)
    table.insert(weeks, week_result)
  end
  return weeks
end

-- Sort weeks chronologically
local function sort_weeks_chronologically(weeks)
  table.sort(weeks, function(a, b)
    return a.week > b.week
  end)
  return weeks
end

-- Process timesheets by week and sort chronologically
local function process_and_sort_weeks(timesheets, all_summary)
  local timesheets_by_week = week_processor.group_timesheets_by_week(timesheets)
  local weeks = process_weeks(timesheets_by_week, all_summary)
  return sort_weeks_chronologically(weeks)
end

-- Build final report structure with all data
local function build_final_report(timesheets, all_dates, weeks, all_summary)
  local total_hours = summary_utils.calculate_total_hours(all_summary)
  local summary_array = summary_utils.sort_summary(all_summary)

  return {
    timesheets = timesheets,
    summary = summary_array,
    total_hours = total_hours,
    dates = all_dates,
    date_range = #all_dates > 0 and {first = all_dates[1], last = all_dates[#all_dates]} or nil,
    weeks = weeks
  }
end

-- Generate a complete report for all timesheets
function generator.generate_report()
  local all_dates = data_loader.get_all_timesheet_dates()
  local timesheets = data_loader.load_timesheets(all_dates)

  if #timesheets == 0 then
    return create_empty_report(all_dates)
  end

  local all_summary = {}
  local weeks = process_and_sort_weeks(timesheets, all_summary)

  return build_final_report(timesheets, all_dates, weeks, all_summary)
end

return generator