-- epoch/storage/serializer/table_formatter.lua
-- Table formatting and serialization

local array_detection = require('epoch.storage.serializer.array_detection')

local table_formatter = {}

-- Key order for intervals to ensure consistent serialization
local interval_key_order = {"client", "project", "task", "start", "stop", "notes"}

-- Forward declaration for recursive calls
local serialize_table

-- Format a single value for serialization
local function format_value(value, indent)
  if type(value) == "table" then
    return serialize_table(value, indent)
  elseif type(value) == "string" then
    return "\"" .. value .. "\""
  else
    return tostring(value)
  end
end

-- Serialize array elements
local function serialize_array_elements(tbl, spaces, result, indent)
  for _, value in ipairs(tbl) do
    local formatted_value = format_value(value, indent + 1)
    result = result .. spaces .. "  " .. formatted_value .. ",\n"
  end
  return result
end

-- Serialize interval with predefined key order
local function serialize_interval_keys(tbl, spaces, result, indent)
  for _, key in ipairs(interval_key_order) do
    if tbl[key] ~= nil then
      result = result .. spaces .. "  [\"" .. key .. "\"] = "
      result = result .. format_value(tbl[key], indent + 1)
      result = result .. ",\n"
    end
  end
  return result
end

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
local function serialize_regular_keys(tbl, spaces, result, indent)
  local keys = get_sorted_keys(tbl)
  for _, k in ipairs(keys) do
    local v = tbl[k]
    if type(k) == "string" then
      result = result .. spaces .. "  [\"" .. k .. "\"] = "
    else
      result = result .. spaces .. "  [" .. tostring(k) .. "] = "
    end
    result = result .. format_value(v, indent + 1)
    result = result .. ",\n"
  end
  return result
end

-- Check if table looks like an interval
local function is_interval(tbl)
  return tbl.client and tbl.project and tbl.task and tbl.start
end

-- Serialize table content based on type
local function serialize_table_content(tbl, spaces, indent)
  if array_detection.is_array(tbl) then
    return serialize_array_elements(tbl, spaces, "{\n", indent)
  elseif is_interval(tbl) then
    return serialize_interval_keys(tbl, spaces, "{\n", indent)
  else
    return serialize_regular_keys(tbl, spaces, "{\n", indent)
  end
end

serialize_table = function(tbl, indent)
  indent = indent or 0
  local spaces = string.rep("  ", indent)
  
  local result = serialize_table_content(tbl, spaces, indent)
  result = result .. spaces .. "}"
  return result
end

-- Serialize a Lua table with ordered keys
function table_formatter.serialize_table(tbl, indent)
  return serialize_table(tbl, indent)
end

return table_formatter