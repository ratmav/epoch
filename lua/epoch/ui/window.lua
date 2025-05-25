-- epoch/ui/window.lua
-- Generic floating window management for timesheet and report display

local window = {}

-- Window state tracking
local windows = {}

-- Set up highlight groups based on current colorscheme
local function setup_highlights()
  local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
  local normal_fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg
  
  local highlights = {
    EpochNormal = { default = true, bg = normal_bg, fg = normal_fg },
    EpochBorder = { default = true, bg = normal_bg, fg = normal_fg },
    EpochTitle = { default = true, bg = normal_bg, fg = normal_fg, bold = true },
  }
  
  for k, v in pairs(highlights) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

-- Check if a specific window is open
local function is_window_open(window_id)
  local win_data = windows[window_id]
  return win_data and win_data.window and vim.api.nvim_win_is_valid(win_data.window)
end

-- Close and clean up a specific window
local function close_window(window_id)
  local win_data = windows[window_id]
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
  windows[window_id] = nil
end

-- Create a floating window with specified configuration
function window.create(config)
  local window_id = config.id or "default"
  
  -- Close existing window if open
  if is_window_open(window_id) then
    close_window(window_id)
  end
  
  -- Set defaults
  local width_pct = config.width_percent or 0.5
  local height_pct = config.height_percent or 0.6
  local title = config.title or "epoch"
  local filetype = config.filetype or "text"
  local modifiable = config.modifiable ~= false -- default true
  local content = config.content or ""
  
  -- Create buffer (start as modifiable)
  local buffer = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_option(buffer, 'bufhidden', 'hide')
  vim.api.nvim_buf_set_option(buffer, 'swapfile', false)
  vim.api.nvim_buf_set_option(buffer, 'filetype', filetype)
  
  -- Set buffer name if provided
  if config.buffer_name then
    vim.api.nvim_buf_set_name(buffer, config.buffer_name)
  end
  
  -- Set content first (while buffer is modifiable)
  if content and content ~= "" then
    local lines = vim.split(content, '\n')
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  end
  
  -- Now set final modifiable state
  vim.api.nvim_buf_set_option(buffer, 'modifiable', modifiable)
  
  -- Calculate window dimensions
  local width = math.floor(vim.o.columns * width_pct)
  local height = math.floor(vim.o.lines * height_pct)
  
  -- Create floating window
  local win = vim.api.nvim_open_win(buffer, true, {
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
  
  -- Set up keymaps
  local opts = { noremap = true, silent = true }
  local close_cmd = string.format(':lua require("epoch.ui.window").close("%s")<CR>', window_id)
  vim.api.nvim_buf_set_keymap(buffer, 'n', 'q', close_cmd, opts)
  vim.api.nvim_buf_set_keymap(buffer, 'n', '<Esc>', close_cmd, opts)
  
  -- Add custom keymaps if provided (excluding manual save)
  if config.keymaps then
    for key, cmd in pairs(config.keymaps) do
      -- Skip 'w' keymap - no manual saving, only save on close
      if key ~= 'w' then
        vim.api.nvim_buf_set_keymap(buffer, 'n', key, cmd, opts)
      end
    end
  end
  
  -- Track window state
  windows[window_id] = {
    window = win,
    buffer = buffer,
    config = config
  }
  
  return {
    window = win,
    buffer = buffer,
    close = function() close_window(window_id) end
  }
end

-- Close a specific window
function window.close(window_id)
  close_window(window_id or "default")
end

-- Check if a window is open
function window.is_open(window_id)
  return is_window_open(window_id or "default")
end

-- Toggle a window (close if open, create if closed)
function window.toggle(config)
  local window_id = config.id or "default"
  
  if is_window_open(window_id) then
    close_window(window_id)
  else
    return window.create(config)
  end
end

-- Get buffer content from a window
function window.get_content(window_id)
  local win_data = windows[window_id or "default"]
  if not win_data or not vim.api.nvim_buf_is_valid(win_data.buffer) then
    return nil
  end
  
  local lines = vim.api.nvim_buf_get_lines(win_data.buffer, 0, -1, false)
  return table.concat(lines, "\n")
end

-- Update buffer content in a window
function window.set_content(window_id, content)
  local win_data = windows[window_id or "default"]
  if not win_data or not vim.api.nvim_buf_is_valid(win_data.buffer) then
    return false
  end
  
  local lines = vim.split(content, '\n')
  local was_modifiable = vim.api.nvim_buf_get_option(win_data.buffer, 'modifiable')
  
  -- Temporarily make buffer modifiable
  vim.api.nvim_buf_set_option(win_data.buffer, 'modifiable', true)
  vim.api.nvim_buf_set_lines(win_data.buffer, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(win_data.buffer, 'modifiable', was_modifiable)
  vim.api.nvim_buf_set_option(win_data.buffer, 'modified', false)
  
  return true
end

-- Initialize window system
function window.setup()
  setup_highlights()
  
  -- Listen for colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = setup_highlights,
    group = vim.api.nvim_create_augroup("EpochWindowHighlights", { clear = true }),
  })
  
  -- Handle QuitPre to save modified buffers
  vim.api.nvim_create_autocmd("QuitPre", {
    callback = function()
      for _, win_data in pairs(windows) do
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

return window