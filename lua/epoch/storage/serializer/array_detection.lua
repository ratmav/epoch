-- epoch/storage/serializer/array_detection.lua
-- Array detection utilities

local array_detection = {}

-- Check if a table is an array (all keys are consecutive integers starting from 1)
function array_detection.is_array(tbl)
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

return array_detection