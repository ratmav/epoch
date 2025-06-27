-- controllers/report/aggregation.lua
-- Report aggregation and summary operations

local aggregation = {}
local timesheet_model = require('epoch.models.timesheet')
local interval_model = require('epoch.models.interval')

-- Create summary key for grouping intervals
local function create_summary_key(this_interval)
  return this_interval.client .. "|" .. this_interval.project .. "|" .. this_interval.task
end

-- Create summary entry for an interval
local function create_summary_entry(this_interval)
  return {
    client = this_interval.client,
    project = this_interval.project,
    task = this_interval.task,
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

-- Private: aggregate intervals into summary dictionary
local function aggregate_intervals(summary_dict, this_timesheet)
  local completed_intervals = timesheet_model.get_completed_intervals(this_timesheet)

  for _, this_interval in ipairs(completed_intervals) do
    local key = create_summary_key(this_interval)

    if not summary_dict[key] then
      summary_dict[key] = create_summary_entry(this_interval)
    end

    summary_dict[key].minutes = summary_dict[key].minutes + interval_model.calculate_duration_minutes(this_interval)
  end
end

-- Calculate summary by aggregating intervals across timesheets
function aggregation.calculate_summary(this_report)
  local summary_dict = {}

  for _, this_timesheet in ipairs(this_report.timesheets) do
    aggregate_intervals(summary_dict, this_timesheet)
  end

  this_report.summary = sort_summary(summary_dict)
end

return aggregation
