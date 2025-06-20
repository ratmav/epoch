-- epoch/ui/window/buffer/content.lua
-- Buffer content operations

local content = {}

-- Set buffer content
function content.set(buf, content_text, modifiable)
  if content_text and content_text ~= "" then
    local lines = vim.split(content_text, '\n')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  -- Set final modifiable state (default true unless specified false)
  vim.api.nvim_buf_set_option(buf, 'modifiable', modifiable ~= false)
end

-- Get buffer content
function content.get(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return table.concat(lines, "\n")
end

-- Set buffer content with modifiable handling
local function set_buffer_content(buf, lines, was_modifiable)
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', was_modifiable)
  vim.api.nvim_buf_set_option(buf, 'modified', false)
end

-- Update buffer content
function content.update(buf, content_text)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  local lines = vim.split(content_text, '\n')
  local was_modifiable = vim.api.nvim_buf_get_option(buf, 'modifiable')

  set_buffer_content(buf, lines, was_modifiable)
  return true
end

return content