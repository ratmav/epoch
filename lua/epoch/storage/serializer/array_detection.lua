-- epoch/storage/serializer/array_detection.lua
-- Array detection utilities

local array_detection = {}

function array_detection.count_table_entries(tbl)
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

function array_detection.has_consecutive_keys(tbl, count)
  for i = 1, count do
    if tbl[i] == nil then
      return false
    end
  end
  return true
end

-- Check if a table is an array (all keys are consecutive integers starting from 1)
function array_detection.is_array(tbl)
  if type(tbl) ~= "table" then
    return false
  end
  local count = array_detection.count_table_entries(tbl)
  return array_detection.has_consecutive_keys(tbl, count)
end

return array_detection