-- epoch/ui/workflow.lua
-- UI workflow coordination (delegates to logic layer)

local workflow_logic = require('epoch.ui.logic.workflow')

local workflow = {}

-- Re-export logic functions for backward compatibility
workflow.add_interval = workflow_logic.add_interval

return workflow