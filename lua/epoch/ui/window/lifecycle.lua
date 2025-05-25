-- epoch/ui/window/lifecycle.lua
-- Window creation and destruction lifecycle

local state = require("epoch.ui.window.state")
local buffer_ops = require("epoch.ui.window.buffer")

local lifecycle = {}

-- Create a floating window with calculated dimensions
function lifecycle.create_window(buf, config)
  -- Set defaults
  local width_pct = config.width_percent or 0.5
  local height_pct = config.height_percent or 0.6
  local title = config.title or "epoch"
  
  -- Calculate window dimensions
  local width = math.floor(vim.o.columns * width_pct)
  local height = math.floor(vim.o.lines * height_pct)
  
  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'winfixheight', true)
  vim.api.nvim_win_set_option(win, 'winfixwidth', true)
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:EpochNormal,FloatBorder:EpochBorder')
  
  return win
end

-- Close and clean up a specific window
function lifecycle.close_window(window_id)
  local win_data = state.get(window_id)
  if not win_data then return end
  
  -- Save if buffer is modified and has save callback
  if win_data.buffer and vim.api.nvim_buf_is_valid(win_data.buffer) 
     and vim.api.nvim_buf_get_option(win_data.buffer, 'modified')
     and win_data.config.on_save then
    local save_success = win_data.config.on_save()
    if not save_success then
      return -- Don't close if save failed
    end
  end
  
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

-- Setup QuitPre autocmd for save handling
function lifecycle.setup_quit_handler()
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

return lifecycle