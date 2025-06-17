-- epoch/ui/window/buffer.lua
-- Buffer operations for floating windows
-- coverage: no tests

local buffer = {}

-- Get or create buffer with given name
local function get_or_create_buffer(buffer_name)
  if not buffer_name then
    return vim.api.nvim_create_buf(false, false)
  end

  local existing_buf = vim.fn.bufnr(buffer_name)
  if existing_buf ~= -1 and vim.api.nvim_buf_is_valid(existing_buf) then
    return existing_buf
  end

  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(buf, buffer_name)
  return buf
end

-- Create and configure a buffer
function buffer.create(config)
  local buf = get_or_create_buffer(config.buffer_name)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', config.filetype or "text")

  return buf
end

-- Set buffer content
function buffer.set_content(buf, content, modifiable)
  if content and content ~= "" then
    local lines = vim.split(content, '\n')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  -- Set final modifiable state (default true unless specified false)
  vim.api.nvim_buf_set_option(buf, 'modifiable', modifiable ~= false)
end

-- Get buffer content
function buffer.get_content(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return table.concat(lines, "\n")
end

-- Update buffer content
-- Set buffer content with modifiable handling
local function set_buffer_content(buf, lines, was_modifiable)
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', was_modifiable)
  vim.api.nvim_buf_set_option(buf, 'modified', false)
end

function buffer.update_content(buf, content)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  local lines = vim.split(content, '\n')
  local was_modifiable = vim.api.nvim_buf_get_option(buf, 'modifiable')

  set_buffer_content(buf, lines, was_modifiable)
  return true
end

-- Setup keymaps for buffer
function buffer.setup_keymaps(buf, window_id, custom_keymaps)
  local opts = { noremap = true, silent = true }
  local close_cmd = string.format(':lua require("epoch.ui.window").close("%s")<CR>', window_id)

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', close_cmd, opts)
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', close_cmd, opts)

  -- Add custom keymaps if provided (excluding manual save)
  if custom_keymaps then
    for key, cmd in pairs(custom_keymaps) do
      -- Skip 'w' keymap - no manual saving, only save on close
      if key ~= 'w' then
        vim.api.nvim_buf_set_keymap(buf, 'n', key, cmd, opts)
      end
    end
  end
end

return buffer