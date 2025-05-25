-- epoch/report/generator/processor/week.lua
-- Week-level timesheet processing

local week_utils = require('epoch.report.week_utils')
local day_processor = require('epoch.report.generator.processor.day')
local summary_utils = require('epoch.report.generator.summary_utils')

local week = {}

-- Group timesheets by week
function week.group_timesheets_by_week(timesheets)
  local timesheets_by_week = {}
  
  for _, timesheet in ipairs(timesheets) do
    local week_num = week_utils.get_week_number(timesheet.date)
    if week_num then
      if not timesheets_by_week[week_num] then
        timesheets_by_week[week_num] = {
          dates = {},
          timesheets = {},
          date_range = week_utils.get_week_date_range(week_num)
        }
      end
      
      table.insert(timesheets_by_week[week_num].dates, timesheet.date)
      table.insert(timesheets_by_week[week_num].timesheets, timesheet)
    end
  end
  
  return timesheets_by_week
end

-- Process week data and create week summary
function week.process_week_data(week_num, week_data, all_summary)
  local week_summary = {}
  local daily_totals = {}
  
  -- Sort the timesheet dates in chronological order
  table.sort(week_data.dates)
  
  -- Process each timesheet in this week
  for _, timesheet in ipairs(week_data.timesheets) do
    local day_total = day_processor.process_timesheet_intervals(timesheet, week_summary, all_summary)
    daily_totals[timesheet.date] = day_total
  end
  
  -- Calculate week total and convert to sorted array
  local week_total_minutes = summary_utils.calculate_total_minutes(week_summary)
  local week_summary_array = summary_utils.sort_summary(week_summary)
  
  return {
    week = week_num,
    dates = week_data.dates,
    summary = week_summary_array,
    total_minutes = week_total_minutes,
    date_range = week_data.date_range,
    daily_totals = daily_totals
  }
end

return week