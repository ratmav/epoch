-- controllers/report/init.lua
-- Report controller delegation

local report = {}
local generation = require('controllers.report.generation')
local aggregation = require('controllers.report.aggregation')

-- Delegate to generation module
report.create = generation.create
report.add_timesheet = generation.add_timesheet
report.calculate_total_minutes = generation.calculate_total_minutes

-- Delegate to aggregation module
report.calculate_summary = aggregation.calculate_summary

return report