-- epoch/storage/serializer.lua
-- Table serialization logic for timesheet data

local serializer = {}

-- Key order for intervals to ensure consistent serialization
local interval_key_order = {"client", "project", "task", "start", "stop", "notes"}

-- Check if a table is an array (all keys are consecutive integers starting from 1)
local function is_array(tbl)
  if type(tbl) ~= "table" then
    return false
  end
  
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  
  for i = 1, count do
    if tbl[i] == nil then
      return false
    end
  end
  
  return true
end

-- Serialize a Lua table with ordered keys
local function serialize_table(tbl, indent)
  indent = indent or 0
  local spaces = string.rep("  ", indent)
  local result = "{\n"
  
  -- Handle different table types differently
  if is_array(tbl) then
    -- It's a list/array, preserve order
    for _, value in ipairs(tbl) do
      if type(value) == "table" then
        result = result .. spaces .. "  " .. serialize_table(value, indent + 1) .. ",\n"
      elseif type(value) == "string" then
        result = result .. spaces .. "  \"" .. value .. "\",\n"
      else
        result = result .. spaces .. "  " .. tostring(value) .. ",\n"
      end
    end
  else
    -- Handle interval specially for key ordering
    if tbl.client and tbl.project and tbl.task and tbl.start then
      -- This looks like an interval - use predefined key order
      for _, key in ipairs(interval_key_order) do
        if tbl[key] ~= nil then
          result = result .. spaces .. "  [\"" .. key .. "\"] = "
          
          if type(tbl[key]) == "table" then
            result = result .. serialize_table(tbl[key], indent + 1)
          elseif type(tbl[key]) == "string" then
            result = result .. "\"" .. tbl[key] .. "\""
          else
            result = result .. tostring(tbl[key])
          end
          
          result = result .. ",\n"
        end
      end
    else
      -- Normal table - sort keys for consistency
      local keys = {}
      for k in pairs(tbl) do
        table.insert(keys, k)
      end
      table.sort(keys)
      
      for _, k in ipairs(keys) do
        local v = tbl[k]
        if type(k) == "string" then
          result = result .. spaces .. "  [\"" .. k .. "\"] = "
        else
          result = result .. spaces .. "  [" .. tostring(k) .. "] = "
        end
        
        if type(v) == "table" then
          result = result .. serialize_table(v, indent + 1)
        elseif type(v) == "string" then
          result = result .. "\"" .. v .. "\""
        else
          result = result .. tostring(v)
        end
        
        result = result .. ",\n"
      end
    end
  end
  
  result = result .. spaces .. "}"
  return result
end

-- Sort intervals in a timesheet by start time
local function sort_intervals(timesheet)
  if not timesheet.intervals or #timesheet.intervals <= 1 then
    return timesheet
  end
  
  local sorted = {}
  for _, interval in ipairs(timesheet.intervals) do
    table.insert(sorted, interval)
  end
  
  table.sort(sorted, function(a, b)
    if not a.start then return false end
    if not b.start then return true end
    return a.start < b.start
  end)
  
  timesheet.intervals = sorted
  return timesheet
end

-- Serialize a timesheet to a string representation
function serializer.serialize_timesheet(timesheet)
  local sorted_timesheet = sort_intervals(timesheet)
  return "return " .. serialize_table(sorted_timesheet)
end

return serializer