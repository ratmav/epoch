-- epoch/storage/serializer/array_serializer.lua
-- Array serialization utilities

local array_serializer = {}
local value_formatter = require('epoch.storage.serializer.value_formatter')

-- Serialize array elements
function array_serializer.serialize_array_elements(tbl, spaces, result, indent)
  for _, value in ipairs(tbl) do
    local formatted_value = value_formatter.format_value(value, indent + 1)
    result = result .. spaces .. "  " .. formatted_value .. ",\n"
  end
  return result
end

return array_serializer