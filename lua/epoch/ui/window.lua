-- epoch/ui/window.lua
-- Generic floating window management for timesheet and report display
-- coverage: no tests

local state = require("epoch.ui.window.state")
local buffer_ops = require("epoch.ui.window.buffer")
local lifecycle = require("epoch.ui.window.lifecycle")
local highlights = require("epoch.ui.window.highlights")

local window = {}

-- Create a floating window with specified configuration
-- Prepare window creation by closing existing if needed
local function prepare_window_creation(window_id)
  if state.is_open(window_id) then
    lifecycle.close_window(window_id)
  end
end

-- Create and setup buffer
local function create_and_setup_buffer(config)
  local buffer = buffer_ops.create(config)
  buffer_ops.set_content(buffer, config.content, config.modifiable)
  return buffer
end

-- Track and return window result
local function track_and_return_window(window_id, win, buffer, config)
  state.track(window_id, {
    window = win,
    buffer = buffer,
    config = config
  })

  return {
    window = win,
    buffer = buffer,
    close = function() lifecycle.close_window(window_id) end
  }
end

function window.create(config)
  local window_id = config.id or "default"

  prepare_window_creation(window_id)
  local buffer = create_and_setup_buffer(config)
  local win = lifecycle.create_window(buffer, config)

  buffer_ops.setup_keymaps(buffer, window_id, config.keymaps)

  return track_and_return_window(window_id, win, buffer, config)
end

-- Close a specific window
function window.close(window_id)
  lifecycle.close_window(window_id or "default")
end

-- Check if a window is open
function window.is_open(window_id)
  return state.is_open(window_id or "default")
end

-- Toggle a window (close if open, create if closed)
function window.toggle(config)
  local window_id = config.id or "default"

  if state.is_open(window_id) then
    lifecycle.close_window(window_id)
  else
    return window.create(config)
  end
end

-- Get buffer content from a window
function window.get_content(window_id)
  local win_data = state.get(window_id or "default")
  if not win_data then return nil end

  return buffer_ops.get_content(win_data.buffer)
end

-- Update buffer content in a window
function window.set_content(window_id, content)
  local win_data = state.get(window_id or "default")
  if not win_data then return false end

  return buffer_ops.update_content(win_data.buffer, content)
end

-- Initialize window system
function window.setup()
  highlights.setup()
  highlights.setup_autocmd()
  lifecycle.setup_quit_handler()
end

return window