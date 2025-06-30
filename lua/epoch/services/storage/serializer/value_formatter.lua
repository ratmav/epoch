-- epoch/storage/serializer/value_formatter.lua
-- Basic value formatting for serialization

local value_formatter = {}

-- Forward declaration for recursive calls (set by table_formatter)
value_formatter.serialize_table = nil

-- Format a single value for serialization
function value_formatter.format_value(value, indent)
  if type(value) == "table" then
    return value_formatter.serialize_table(value, indent)
  elseif type(value) == "string" then
    return "\"" .. value .. "\""
  else
    return tostring(value)
  end
end

return value_formatter