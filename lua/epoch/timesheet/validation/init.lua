-- epoch/timesheet/validation/init.lua
-- Delegates to timesheet validation modules

local validation = {}

validation.fields = require('epoch.timesheet.validation.fields')
validation.intervals = require('epoch.timesheet.validation.intervals')
validation.overlap = require('epoch.timesheet.validation.overlap')
validation.open_intervals = require('epoch.timesheet.validation.open_intervals')

return validation