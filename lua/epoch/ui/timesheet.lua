-- epoch/ui/timesheet.lua
-- Timesheet validation, manipulation, and save operations

local validation = require('epoch.validation')
local storage = require('epoch.storage')
local window = require('epoch.ui.window')

local timesheet = {}

-- Validate and prepare timesheet content
-- Returns: timesheet, nil on success OR nil, error_message on failure
function timesheet.validate_content(content)
  -- Use protected call to load and execute the Lua content
  local chunk, err = loadstring(content, "timesheet")
  if not chunk then
    return nil, "lua syntax error: " .. tostring(err)
  end
  
  local ok, timesheet_data = pcall(chunk)
  if not ok then
    return nil, "execution error: " .. tostring(timesheet_data)
  end
  
  if type(timesheet_data) ~= "table" then
    return nil, "invalid timesheet format (not a table)"
  end
  
  -- Validate timesheet structure
  local valid, validation_err = validation.validate_timesheet(timesheet_data)
  if not valid then
    return nil, validation_err
  end
  
  return timesheet_data, nil
end

-- Update daily total in a timesheet
-- Returns: updated timesheet
function timesheet.update_daily_total(timesheet_data, calculate_fn)
  local updated = vim.deepcopy(timesheet_data)
  updated.daily_total = calculate_fn(updated)
  return updated
end

-- Validate and save timesheet from buffer
function timesheet.validate_and_save_from_buffer()
  -- Parse buffer content
  local content = window.get_content("timesheet")
  if not content then
    vim.notify("epoch: cannot save timesheet - buffer is not valid", vim.log.levels.ERROR)
    return false
  end
  
  -- Validate content
  local timesheet_data, err = timesheet.validate_content(content)
  if not timesheet_data then
    vim.notify("epoch: cannot save timesheet - " .. err, vim.log.levels.ERROR)
    return false
  end
  
  -- Save to file
  local success, save_err = storage.save_timesheet(timesheet_data)
  if not success then
    vim.notify("epoch: failed to save - " .. tostring(save_err), vim.log.levels.ERROR)
    return false
  end
  
  vim.notify("epoch: timesheet saved", vim.log.levels.INFO)
  return true
end

return timesheet