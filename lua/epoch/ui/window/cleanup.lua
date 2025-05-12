-- epoch/ui/window/cleanup.lua
-- Window cleanup and resource management
-- coverage: no tests

local state = require("epoch.ui.window.state")

local cleanup = {}

-- Validate and get window data
local function validate_window_data(window_id)
  local win_data = state.get(window_id)
  if not win_data then
    return nil
  end
  return win_data
end

-- Handle buffer save if modified
local function handle_buffer_save(win_data)
  if win_data.buffer and vim.api.nvim_buf_is_valid(win_data.buffer)
     and vim.api.nvim_buf_get_option(win_data.buffer, 'modified')
     and win_data.config.on_save then
    local save_success = win_data.config.on_save()
    if not save_success then
      return false -- Save failed
    end
  end
  return true -- Save successful or not needed
end

-- Cleanup window, buffer, and state tracking
local function cleanup_window_resources(win_data, window_id)
  -- Close window
  if win_data.window and vim.api.nvim_win_is_valid(win_data.window) then
    vim.api.nvim_win_close(win_data.window, true)
  end

  -- Clean up buffer
  if win_data.buffer and vim.api.nvim_buf_is_valid(win_data.buffer) then
    vim.api.nvim_buf_delete(win_data.buffer, { force = true })
  end

  -- Clear from tracking
  state.untrack(window_id)
end

-- Close and clean up a specific window
function cleanup.close_window(window_id)
  local win_data = validate_window_data(window_id)
  if not win_data then return end

  local save_success = handle_buffer_save(win_data)
  if not save_success then return end

  cleanup_window_resources(win_data, window_id)
end

-- Setup QuitPre autocmd for save handling
function cleanup.setup_quit_handler()
  vim.api.nvim_create_autocmd("QuitPre", {
    callback = function()
      for _, win_data in pairs(state.get_all()) do
        if win_data.buffer and vim.api.nvim_buf_is_valid(win_data.buffer)
           and vim.api.nvim_buf_get_option(win_data.buffer, 'modified')
           and win_data.config.on_save then
          win_data.config.on_save()
        end
      end
    end,
    group = vim.api.nvim_create_augroup("EpochWindowQuitHandler", { clear = true }),
  })
end

return cleanup