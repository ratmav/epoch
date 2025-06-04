-- epoch/ui/timesheet.lua
-- Timesheet UI operations (save/load from buffer)

local storage = require('epoch.storage')
local window = require('epoch.ui.window')
local timesheet_logic = require('epoch.ui.logic.timesheet')

local timesheet = {}

-- Re-export logic functions for backward compatibility
timesheet.validate_content = timesheet_logic.validate_content
timesheet.update_daily_total = timesheet_logic.update_daily_total

-- Validate and save timesheet from buffer
-- Get and validate buffer content
local function get_and_validate_content()
  local content = window.get_content("timesheet")
  if not content then
    vim.notify("epoch: cannot save timesheet - buffer is not valid", vim.log.levels.ERROR)
    return nil
  end

  local timesheet_data, err = timesheet.validate_content(content)
  if not timesheet_data then
    vim.notify("epoch: cannot save timesheet - " .. err, vim.log.levels.ERROR)
    return nil
  end

  return timesheet_data
end

-- Save timesheet data to file
local function save_timesheet_data(timesheet_data)
  local success, save_err = storage.save_timesheet(timesheet_data)
  if not success then
    vim.notify("epoch: failed to save - " .. tostring(save_err), vim.log.levels.ERROR)
    return false
  end

  vim.notify("epoch: timesheet saved", vim.log.levels.INFO)
  return true
end

function timesheet.validate_and_save_from_buffer()
  local timesheet_data = get_and_validate_content()
  if not timesheet_data then
    return false
  end

  return save_timesheet_data(timesheet_data)
end

return timesheet