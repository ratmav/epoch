-- epoch/ui/init.lua
-- UI functionality for epoch time tracking

local ui = {}
local storage = require('epoch.storage')
local window = require('epoch.ui.window')
local timesheet = require('epoch.ui.timesheet')
local input = require('epoch.ui.input')


-- Ensure timesheet file exists, create if needed
local function ensure_timesheet_exists(timesheet_path)
  if vim.fn.filereadable(timesheet_path) == 0 then
    local timesheet = storage.create_default_timesheet()
    storage.save_timesheet(timesheet)
  end
end

-- Load timesheet content from file
local function load_timesheet_content(timesheet_path)
  return table.concat(vim.fn.readfile(timesheet_path), '\n')
end

-- Create timesheet window with configuration
local function create_timesheet_window(content, timesheet_path)
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

-- Open timesheet window
local function open_timesheet()
  local timesheet_path = storage.get_timesheet_path()
  ensure_timesheet_exists(timesheet_path)
  local content = load_timesheet_content(timesheet_path)
  create_timesheet_window(content, timesheet_path)
end

-- Set up the UI module
function ui.setup()
  -- Set up the window system
  window.setup()
end

-- Toggle timesheet window
-- Handle timesheet opening logic
local function handle_timesheet_open()
  local path = storage.get_timesheet_path()
  
  if vim.fn.filereadable(path) == 0 then
    ui.add_interval_and_edit()
  else
    open_timesheet()
  end
end

function ui.toggle_timesheet()
  if window.is_open("timesheet") then
    window.close("timesheet")
  else
    handle_timesheet_open()
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