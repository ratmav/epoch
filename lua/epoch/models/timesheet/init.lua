-- models/timesheet/init.lua
-- Timesheet module delegation

local timesheet = {}
local creation = require('epoch.models.timesheet.creation')
local calculation = require('epoch.models.timesheet.calculation')
local query = require('epoch.models.timesheet.query')
local validation = require('epoch.models.timesheet.validation')

-- Delegate to creation module
timesheet.create = creation.create
timesheet.add_interval = function(this_timesheet, interval)
  creation.add_interval(this_timesheet, interval)
  calculation.update_daily_total(this_timesheet)
end
timesheet.close_current_interval = creation.close_current_interval

-- Delegate to calculation module
timesheet.calculate_daily_total = calculation.calculate_daily_total

-- Delegate to query module
timesheet.has_open_interval = query.has_open_interval
timesheet.get_completed_intervals = query.get_completed_intervals
timesheet.get_by_date_range = query.get_by_date_range
timesheet.group_by_week = query.group_by_week

-- Delegate to validation module
timesheet.validate = validation.validate

return timesheet