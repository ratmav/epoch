-- epoch/interval/validation/required_fields.lua
-- Validate required fields in interval

local required_fields = {}

function required_fields.validate(current_interval)
  if current_interval.client == nil or current_interval.client == "" then
    return false, "client cannot be empty"
  end
  if current_interval.project == nil or current_interval.project == "" then
    return false, "project cannot be empty"
  end
  if current_interval.task == nil or current_interval.task == "" then
    return false, "task cannot be empty"
  end
  return true
end

return required_fields