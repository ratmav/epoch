-- controllers/report/generation.lua
-- Report generation and basic operations

local generation = {}
local timesheet_model = require('epoch.models.timesheet')
local interval_model = require('epoch.models.interval')

-- Create a new empty report
function generation.create()
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
local function update_date_range(this_report)
  if #this_report.dates == 0 then
    this_report.date_range = nil
    return
  end

  local sorted_dates = {}
  for _, date in ipairs(this_report.dates) do
    table.insert(sorted_dates, date)
  end
  table.sort(sorted_dates)

  this_report.date_range = {
    first = sorted_dates[1],
    last = sorted_dates[#sorted_dates]
  }
end

-- Add timesheet to report and update totals
function generation.add_timesheet(this_report, this_timesheet)
  table.insert(this_report.timesheets, this_timesheet)
  table.insert(this_report.dates, this_timesheet.date)

  -- Add minutes from completed intervals
  local completed_intervals = timesheet_model.get_completed_intervals(this_timesheet)
  for _, this_interval in ipairs(completed_intervals) do
    this_report.total_minutes = this_report.total_minutes + interval_model.calculate_duration_minutes(this_interval)
  end

  update_date_range(this_report)
end

-- Calculate total minutes from all completed intervals
function generation.calculate_total_minutes(this_report)
  local total = 0

  for _, this_timesheet in ipairs(this_report.timesheets) do
    local completed_intervals = timesheet_model.get_completed_intervals(this_timesheet)

    for _, this_interval in ipairs(completed_intervals) do
      total = total + interval_model.calculate_duration_minutes(this_interval)
    end
  end

  return total
end

-- Get timesheets within date range
function generation.get_timesheets_by_date_range(this_report, start_date, end_date)
  return timesheet_model.get_by_date_range(this_report.timesheets, start_date, end_date)
end

-- Group timesheets by week
function generation.group_by_week(this_report)
  this_report.weeks = timesheet_model.group_by_week(this_report.timesheets)
end

-- Private: check required fields
local function check_required_fields(this_report)
  local required = {"timesheets", "summary", "total_minutes", "dates", "weeks"}
  for _, field in ipairs(required) do
    if not this_report[field] then
      return false, "Report must have " .. field .. " array"
    end
  end
  return true
end

-- Validate report structure
function generation.validate(this_report)
  if not this_report then
    return false, "Report cannot be nil"
  end
  return check_required_fields(this_report)
end

return generation
