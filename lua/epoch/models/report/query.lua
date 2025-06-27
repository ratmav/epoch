-- models/report/query.lua
-- Report query operations

local query = {}
local timesheet_model = require('epoch.models.timesheet')

-- Get timesheets within date range
function query.get_timesheets_by_date_range(this_report, start_date, end_date)
  return timesheet_model.get_by_date_range(this_report.timesheets, start_date, end_date)
end

return query