-- epoch/storage/serializer.lua
-- Table serialization logic for timesheet data

local serializer = {}
local interval_sorter = require('epoch.storage.serializer.interval_sorter')
local array_detection = require('epoch.storage.serializer.array_detection')
local value_formatter = require('epoch.storage.serializer.value_formatter')
local array_serializer = require('epoch.storage.serializer.array_serializer')
local interval_serializer = require('epoch.storage.serializer.interval_serializer')
local table_serializer = require('epoch.storage.serializer.table_serializer')

-- Forward declaration for recursive calls
local serialize_table

-- Serialize table content based on type
local function serialize_table_content(tbl, spaces, indent)
  if array_detection.is_array(tbl) then
    return array_serializer.serialize_array_elements(tbl, spaces, "{\n", indent)
  elseif interval_serializer.is_interval(tbl) then
    return interval_serializer.serialize_interval_keys(tbl, spaces, "{\n", indent)
  else
    return table_serializer.serialize_regular_keys(tbl, spaces, "{\n", indent)
  end
end

serialize_table = function(tbl, indent)
  indent = indent or 0
  local spaces = string.rep("  ", indent)

  local result = serialize_table_content(tbl, spaces, indent)
  result = result .. spaces .. "}"
  return result
end

-- Set up circular dependency
value_formatter.serialize_table = serialize_table

-- Serialize a timesheet to a string representation
function serializer.serialize_timesheet(timesheet)
  local sorted_timesheet = interval_sorter.sort_intervals(timesheet)
  return "return " .. serialize_table(sorted_timesheet)
end

-- Export serialize_table for other modules that need it
function serializer.serialize_table(tbl, indent)
  return serialize_table(tbl, indent)
end

return serializer