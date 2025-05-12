-- epoch/ui/window/creation.lua
-- Window creation utilities
-- coverage: no tests

local window_config = require("epoch.ui.window.config")

local creation = {}

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
function creation.create_window(buf, config)
  local width_pct, height_pct, title = window_config.set_defaults(config)
  local width, height = window_config.calculate_dimensions(width_pct, height_pct)
  local win = create_floating_window(buf, width, height, title)
  setup_window_options(win)
  return win
end

return creation