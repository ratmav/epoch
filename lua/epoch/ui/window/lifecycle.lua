-- epoch/ui/window/lifecycle.lua
-- Window creation and destruction lifecycle

local state = require("epoch.ui.window.state")
local buffer_ops = require("epoch.ui.window.buffer")

local lifecycle = {}

-- Set default configuration values
local function set_config_defaults(config)
  local width_pct = config.width_percent or 0.5
  local height_pct = config.height_percent or 0.6
  local title = config.title or "epoch"
  return width_pct, height_pct, title
end

-- Calculate window dimensions based on percentages
local function calculate_dimensions(width_pct, height_pct)
  local width = math.floor(vim.o.columns * width_pct)
  local height = math.floor(vim.o.lines * height_pct)
  return width, height
end

-- Create floating window with nvim API
local function create_floating_window(buf, width, height, title)
  return vim.api.nvim_open_win(buf, true, {
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
end

-- Setup window-specific options
local function setup_window_options(win)
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'winfixheight', true)
  vim.api.nvim_win_set_option(win, 'winfixwidth', true)
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:EpochNormal,FloatBorder:EpochBorder')
end

-- Create a floating window with calculated dimensions
function lifecycle.create_window(buf, config)
  local width_pct, height_pct, title = set_config_defaults(config)
  local width, height = calculate_dimensions(width_pct, height_pct)
  local win = create_floating_window(buf, width, height, title)
  setup_window_options(win)
  return win
end

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
function lifecycle.close_window(window_id)
  local win_data = validate_window_data(window_id)
  if not win_data then return end
  
  local save_success = handle_buffer_save(win_data)
  if not save_success then return end
  
  cleanup_window_resources(win_data, window_id)
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