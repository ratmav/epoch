-- models/interval/init.lua
-- Interval module delegation

local interval = {}
local creation = require('epoch.models.interval.creation')
local validation = require('epoch.models.interval.validation')
local calculation = require('epoch.models.interval.calculation')

-- Delegate to creation module
interval.create = creation.create
interval.close = creation.close
interval.is_open = creation.is_open

-- Delegate to validation module
interval.is_complete = validation.is_complete
interval.validate = validation.validate

-- Delegate to calculation module
interval.calculate_duration_minutes = calculation.calculate_duration_minutes

return interval