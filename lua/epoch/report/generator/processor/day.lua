-- epoch/report/generator/processor/day.lua
-- Day-level timesheet processing

local week_utils = require('epoch.report.week_utils')

local day = {}

-- Create summary entry for an interval
local function create_summary_entry(interval)
  return {
    client = interval.client,
    project = interval.project,
    task = interval.task,
    minutes = 0
  }
end

-- Update summary with interval data
local function update_summary(summary, interval, minutes)
  local key = interval.client .. "|" .. interval.project .. "|" .. interval.task

  if not summary[key] then
    summary[key] = create_summary_entry(interval)
  end

  summary[key].minutes = summary[key].minutes + minutes
end

-- Check if interval is complete
local function is_complete_interval(interval)
  return interval.client and interval.project and interval.task and interval.start
end

-- Process single interval and update summaries
local function process_interval(interval, date, week_summary, all_summary)
  local minutes = week_utils.calculate_interval_minutes(interval, date)
  update_summary(week_summary, interval, minutes)
  update_summary(all_summary, interval, minutes)
  return minutes
end

-- Process intervals from a single timesheet
function day.process_timesheet_intervals(timesheet, week_summary, all_summary)
  local day_total = 0

  for _, interval in ipairs(timesheet.intervals) do
    if is_complete_interval(interval) then
      day_total = day_total + process_interval(interval, timesheet.date, week_summary, all_summary)
    end
  end

  return day_total
end

return day