-- epoch/interval/validation/init.lua
-- Delegates to validation modules

local validation = {}

validation.required_fields = require('epoch.interval.validation.required_fields')
validation.time_fields = require('epoch.interval.validation.time_fields')
validation.notes_field = require('epoch.interval.validation.notes_field')

return validation