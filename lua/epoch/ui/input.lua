-- epoch/ui/input.lua
-- User input handling for time tracking operations

local input = {}
local workflow = require('epoch.ui.workflow')
local storage = require('epoch.storage')
local window = require('epoch.ui.window')

-- Prompt user for interval details and create interval
function input.prompt_for_interval(callback)
  vim.ui.input({ prompt = "client: " }, function(client)
    if not client or client == "" then return end
    
    vim.ui.input({ prompt = "project: " }, function(project)
      if not project or project == "" then return end
      
      vim.ui.input({ prompt = "task: " }, function(task)
        if not task or task == "" then return end
        
        -- Load current timesheet and use workflow for business logic
        local timesheet = storage.load_timesheet()
        local success, err, updated_timesheet = workflow.add_interval(client, project, task, timesheet)
        
        if not success then
          vim.notify("epoch: " .. err, vim.log.levels.ERROR)
          return
        end
        
        -- Save the updated timesheet
        storage.save_timesheet(updated_timesheet)
        
        -- Notify user
        vim.cmd("redraw!")
        vim.notify("epoch: time tracking started for " .. client .. "/" .. project .. "/" .. task, vim.log.levels.INFO)
        
        -- Refresh window if open
        if window.is_open("timesheet") then
          local content = storage.serialize_timesheet(updated_timesheet)
          window.set_content("timesheet", content)
        end
        
        -- Execute callback if provided
        if callback and type(callback) == "function" then
          callback()
        end
      end)
    end)
  end)
end

return input