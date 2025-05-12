-- epoch/ui/logic/init.lua
-- Pure logic functions for UI operations (testable)
-- coverage: no test
--
-- This module contains business logic extracted from UI modules
-- that can be tested independently of Neovim's UI APIs.
-- The original UI modules delegate to these functions.

local logic = {}

-- Import logic modules
local timesheet_logic = require('epoch.ui.logic.timesheet')
local workflow_logic = require('epoch.ui.logic.workflow')

-- Re-export timesheet logic
logic.validate_timesheet_content = timesheet_logic.validate_content
logic.update_daily_total = timesheet_logic.update_daily_total
logic.ensure_timesheet_exists = timesheet_logic.ensure_timesheet_exists
logic.load_timesheet_content = timesheet_logic.load_timesheet_content

-- Re-export workflow logic
logic.add_interval = workflow_logic.add_interval
logic.create_timesheet_window = workflow_logic.create_timesheet_window
logic.open_timesheet = workflow_logic.open_timesheet
logic.handle_timesheet_open = workflow_logic.handle_timesheet_open

return logic