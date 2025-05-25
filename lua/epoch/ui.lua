-- epoch/ui.lua
-- ui functionality for epoch time tracking

local ui = {}
local ui_logic = require('epoch.ui_logic')
local storage = require('epoch.storage')
local window = require('epoch.ui.window')

-- Parse buffer content to extract timesheet data
local function parse_buffer_content()
  local content = window.get_content("timesheet")
  if not content then
    return nil, "buffer is not valid"
  end
  
  return ui_logic.validate_timesheet_content(content)
end

-- Validate and save timesheet content
local function validate_and_save_timesheet()
  -- Parse and validate buffer content
  local timesheet, err = parse_buffer_content()
  if not timesheet then
    vim.notify("epoch: cannot save timesheet - " .. err, vim.log.levels.ERROR)
    return false
  end
  
  -- Save to file
  local success, save_err = storage.save_timesheet(timesheet)
  if not success then
    vim.notify("epoch: failed to save - " .. tostring(save_err), vim.log.levels.ERROR)
    return false
  end
  
  vim.notify("epoch: timesheet saved", vim.log.levels.INFO)
  return true
end

-- Open timesheet window
local function open_timesheet()
  -- Get the timesheet path for today
  local timesheet_path = storage.get_timesheet_path()
  
  -- Create or load the timesheet file
  if vim.fn.filereadable(timesheet_path) == 0 then
    local timesheet = storage.create_default_timesheet()
    storage.save_timesheet(timesheet)
  end
  
  -- Read file content
  local content = table.concat(vim.fn.readfile(timesheet_path), '\n')
  
  -- Create window using generic window module
  window.create({
    id = "timesheet",
    title = "epoch - timesheet",
    width_percent = 0.4,
    height_percent = 0.7,
    filetype = "lua",
    modifiable = true,
    buffer_name = timesheet_path,
    content = content,
    on_save = validate_and_save_timesheet
  })
end

-- Set up the UI module
function ui.setup()
  -- Set up the window system
  window.setup()
end

-- Toggle timesheet window
function ui.toggle_timesheet()
  -- If window is open, close it (window module handles save on close)
  if window.is_open("timesheet") then
    window.close("timesheet")
  else
    -- Window not open, check if timesheet exists
    local path = storage.get_timesheet_path()
    
    -- If no timesheet exists, prompt to create one and then open the editor
    if vim.fn.filereadable(path) == 0 then
      ui.add_interval_and_edit()
    else
      open_timesheet()
    end
  end
end

-- Add a new interval and then open the timesheet window
function ui.add_interval_and_edit()
  -- Call add_interval first
  ui.add_interval(function()
    -- Then unconditionally open the timesheet window
    open_timesheet()
  end)
end

-- Add a new interval
function ui.add_interval(callback)
  -- Prompt for client, project, and task
  vim.ui.input({ prompt = "client: " }, function(client)
    if not client or client == "" then return end
    
    vim.ui.input({ prompt = "project: " }, function(project)
      if not project or project == "" then return end
      
      vim.ui.input({ prompt = "task: " }, function(task)
        if not task or task == "" then return end
        
        -- Load current timesheet and use ui_logic for business logic
        local timesheet = storage.load_timesheet()
        local success, err, updated_timesheet = ui_logic.add_interval_workflow(client, project, task, timesheet)
        
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

return ui