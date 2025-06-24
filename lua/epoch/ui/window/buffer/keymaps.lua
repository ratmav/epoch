-- epoch/ui/window/buffer/keymaps.lua
-- Buffer keymap management

local keymaps = {}

function keymaps.setup_close_keymaps(buf, window_id, opts)
  local close_cmd = string.format(':lua require("epoch.ui.window").close("%s")<CR>', window_id)
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', close_cmd, opts)
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', close_cmd, opts)
end

function keymaps.setup_custom_keymaps(buf, custom_keymaps, opts)
  if not custom_keymaps then return end
  for key, cmd in pairs(custom_keymaps) do
    -- Skip 'w' keymap - no manual saving, only save on close
    if key ~= 'w' then
      vim.api.nvim_buf_set_keymap(buf, 'n', key, cmd, opts)
    end
  end
end

-- Setup keymaps for buffer
function keymaps.setup(buf, window_id, custom_keymaps)
  local opts = { noremap = true, silent = true }
  keymaps.setup_close_keymaps(buf, window_id, opts)
  keymaps.setup_custom_keymaps(buf, custom_keymaps, opts)
end

return keymaps