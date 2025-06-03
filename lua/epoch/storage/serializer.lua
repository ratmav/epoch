-- epoch/storage/serializer.lua
-- Table serialization logic for timesheet data

local table_formatter = require('epoch.storage.serializer.table_formatter')
local interval_sorter = require('epoch.storage.serializer.interval_sorter')

local serializer = {}

-- Serialize a timesheet to a string representation
function serializer.serialize_timesheet(timesheet)
  local sorted_timesheet = interval_sorter.sort_intervals(timesheet)
  return "return " .. table_formatter.serialize_table(sorted_timesheet)
end

return serializer