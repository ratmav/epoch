-- epoch/ui/window/state.lua
-- Window state tracking and management
-- coverage: no tests

local state = {}

-- Window state tracking
local windows = {}

-- Check if a specific window is open
function state.is_open(window_id)
  local win_data = windows[window_id]
  return win_data and win_data.window and vim.api.nvim_win_is_valid(win_data.window)
end

-- Store window data
function state.track(window_id, win_data)
  windows[window_id] = win_data
end

-- Get window data
function state.get(window_id)
  return windows[window_id]
end

-- Remove window from tracking
function state.untrack(window_id)
  windows[window_id] = nil
end

-- Get all tracked windows
function state.get_all()
  return windows
end

return state