-- models/report/validation.lua
-- Report validation operations

local validation = {}

-- Private: check required fields
local function check_required_fields(this_report)
  local required = {"timesheets", "summary", "total_minutes", "dates", "weeks"}
  for _, field in ipairs(required) do
    if not this_report[field] then
      return false, "Report must have " .. field .. " array"
    end
  end
  return true
end

-- Validate report structure
function validation.validate(this_report)
  if not this_report then
    return false, "Report cannot be nil"
  end
  return check_required_fields(this_report)
end

return validation