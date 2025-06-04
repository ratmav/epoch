-- epoch/ui/logic/init.lua
-- Pure logic functions for UI operations (testable)
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

-- Re-export workflow logic
logic.add_interval = workflow_logic.add_interval

return logic