-- epoch/storage/serializer/table_serializer.lua
-- Regular table serialization utilities

local table_serializer = {}
local value_formatter = require('epoch.storage.serializer.value_formatter')

-- Get sorted keys from table
local function get_sorted_keys(tbl)
  local keys = {}
  for k in pairs(tbl) do
    table.insert(keys, k)
  end
  table.sort(keys)
  return keys
end

-- Serialize regular table keys
function table_serializer.serialize_regular_keys(tbl, spaces, result, indent)
  local keys = get_sorted_keys(tbl)
  for _, k in ipairs(keys) do
    local v = tbl[k]
    if type(k) == "string" then
      result = result .. spaces .. "  [\"" .. k .. "\"] = "
    else
      result = result .. spaces .. "  [" .. tostring(k) .. "] = "
    end
    result = result .. value_formatter.format_value(v, indent + 1)
    result = result .. ",\n"
  end
  return result
end

return table_serializer