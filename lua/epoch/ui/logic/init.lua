-- epoch/ui/logic/init.lua
-- Pure logic functions for UI operations (testable)
-- coverage: no test
--
-- This module contains business logic extracted from UI modules
-- that can be tested independently of Neovim's UI APIs.
-- The original UI modules delegate to these functions.

local logic = {}

-- Import logic modules
local timesheet_workflow = require('epoch.workflow.timesheet')
local timesheet_calculation = require('epoch.timesheet.calculation')
local workflow_logic = require('epoch.ui.logic.workflow')

-- Re-export timesheet logic
logic.validate_timesheet_content = timesheet_workflow.validate_content
logic.update_daily_total = timesheet_calculation.update_daily_total
logic.ensure_timesheet_exists = timesheet_workflow.ensure_timesheet_exists
logic.load_timesheet_content = function(timesheet_path)
  return table.concat(vim.fn.readfile(timesheet_path), '\n')
end

-- Re-export workflow logic
logic.add_interval = workflow_logic.add_interval
logic.create_timesheet_window = workflow_logic.create_timesheet_window
logic.open_timesheet = workflow_logic.open_timesheet
logic.handle_timesheet_open = workflow_logic.handle_timesheet_open

return logic