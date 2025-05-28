-- epoch/validation/fields.lua
-- Field validation main module

local interval_validator = require('epoch.validation.fields.interval')
local timesheet_validator = require('epoch.validation.fields.timesheet')
local context = require('epoch.validation.fields.context')

local fields = {}

-- Re-export interval validation
fields.validate_interval = interval_validator.validate

-- Re-export timesheet validation
fields.validate_timesheet = timesheet_validator.validate

-- Re-export context generation
fields.get_interval_context = context.get_interval_context

return fields