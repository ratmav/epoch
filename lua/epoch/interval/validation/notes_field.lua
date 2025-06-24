-- epoch/interval/validation/notes_field.lua
-- Validate notes field in interval

local notes_field = {}

function notes_field.validate(current_interval)
  if current_interval.notes == nil then
    return false, "notes field is required (should be an empty array or array of strings)"
  end
  if type(current_interval.notes) ~= "table" then
    return false, "notes must be an array of strings"
  end
  for i, note in ipairs(current_interval.notes) do
    if type(note) ~= "string" then
      return false, string.format("note at position %d must be a string", i)
    end
  end
  return true
end

return notes_field