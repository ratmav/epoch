-- epoch/ui/window/buffer/lifecycle.lua
-- Buffer creation, finding, and configuration

local lifecycle = {}

-- Get or create buffer with given name
local function get_or_create_buffer(buffer_name)
  if not buffer_name then
    return vim.api.nvim_create_buf(false, false)
  end

  -- Get the full path that vim would use for this buffer name
  local full_path = vim.fn.fnamemodify(buffer_name, ":p")

  -- Check all existing buffers for matching name
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name == full_path then
        return buf
      end
    end
  end

  -- No existing buffer found, create new one
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(buf, buffer_name)
  return buf
end

-- Create and configure a buffer
function lifecycle.create(config)
  local buf = get_or_create_buffer(config.buffer_name)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', config.filetype or "text")

  return buf
end

return lifecycle