-- epoch/storage/serializer/interval_serializer.lua
-- Interval-specific serialization utilities

local interval_serializer = {}
local value_formatter = require('epoch.storage.serializer.value_formatter')

-- Key order for intervals to ensure consistent serialization
local interval_key_order = {"client", "project", "task", "start", "stop", "notes"}

-- Serialize interval with predefined key order
function interval_serializer.serialize_interval_keys(tbl, spaces, result, indent)
  for _, key in ipairs(interval_key_order) do
    if tbl[key] ~= nil then
      result = result .. spaces .. "  [\"" .. key .. "\"] = "
      result = result .. value_formatter.format_value(tbl[key], indent + 1)
      result = result .. ",\n"
    end
  end
  return result
end

-- Check if table looks like an interval
function interval_serializer.is_interval(tbl)
  if type(tbl) ~= "table" then
    return false
  end
  return not not (tbl.client and tbl.project and tbl.task and tbl.start)
end

return interval_serializer