-- epoch/ui/init.lua
-- UI functionality for epoch time tracking

local ui = {}
local storage = require('epoch.storage')
local window = require('epoch.ui.window')
local timesheet = require('epoch.ui.timesheet')
local input = require('epoch.ui.input')


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
    on_save = timesheet.validate_and_save_from_buffer
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
  input.prompt_for_interval(callback)
end

return ui