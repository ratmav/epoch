-- epoch/ui/timesheet.lua
-- Timesheet UI operations (save/load from buffer)

local storage = require('epoch.storage')
local window = require('epoch.ui.window')
local timesheet_workflow = require('epoch.workflow.timesheet')

local timesheet = {}

-- Validate and save timesheet from buffer
-- Get and validate buffer content
local function get_and_validate_content()
  local content = window.get_content("timesheet")
  if not content then
    vim.notify("epoch: cannot save timesheet - buffer is not valid", vim.log.levels.ERROR)
    return nil
  end

  local timesheet_data, err = timesheet_workflow.validate_content(content)
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

-- Expose functions for testing (temporary - will reorganize tests later)
timesheet.validate_content = timesheet_workflow.validate_content

-- Need to require timesheet calculation for update_daily_total
local timesheet_calculation = require('epoch.timesheet.calculation')
timesheet.update_daily_total = timesheet_calculation.update_daily_total

return timesheet