-- epoch/ui/input.lua
-- User input handling for time tracking operations
-- coverage: no tests

local input = {}
local interval_workflow = require('epoch.workflow.interval')
local storage = require('epoch.storage')
local window = require('epoch.ui.window')

-- Validate user input is not empty
local function validate_input(value)
  return value and value ~= ""
end

-- Handle interval creation and success actions
local function handle_interval_creation(client, project, task, callback)
  local timesheet = storage.load_timesheet()
  local success, err, updated_timesheet = interval_workflow.add_interval(client, project, task, timesheet)

  if not success then
    vim.notify("epoch: " .. err, vim.log.levels.ERROR)
    return
  end

  storage.save_timesheet(updated_timesheet)
  vim.cmd("redraw!")
  vim.notify("epoch: time tracking started for " .. client .. "/" .. project .. "/" .. task, vim.log.levels.INFO)

  if window.is_open("timesheet") then
    local content = storage.serialize_timesheet(updated_timesheet)
    window.set_content("timesheet", content)
  end

  if callback and type(callback) == "function" then
    callback()
  end
end

-- Prompt for task input
local function prompt_for_task(client, project, callback)
  vim.ui.input({ prompt = "task: " }, function(task)
    if not validate_input(task) then return end
    handle_interval_creation(client, project, task, callback)
  end)
end

-- Prompt for project input
local function prompt_for_project(client, callback)
  vim.ui.input({ prompt = "project: " }, function(project)
    if not validate_input(project) then return end
    prompt_for_task(client, project, callback)
  end)
end

-- Prompt user for interval details and create interval
function input.prompt_for_interval(callback)
  vim.ui.input({ prompt = "client: " }, function(client)
    if not validate_input(client) then return end
    prompt_for_project(client, callback)
  end)
end

return input