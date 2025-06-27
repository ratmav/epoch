-- controllers/report/init.lua
-- Report controller delegation

local report = {}
local generation = require('epoch.controllers.report.generation')
local aggregation = require('epoch.controllers.report.aggregation')

-- Delegate to generation module
report.create = generation.create
report.add_timesheet = generation.add_timesheet
report.calculate_total_minutes = generation.calculate_total_minutes
report.get_timesheets_by_date_range = generation.get_timesheets_by_date_range
report.group_by_week = generation.group_by_week
report.validate = generation.validate

-- Delegate to aggregation module
report.calculate_summary = aggregation.calculate_summary

return report