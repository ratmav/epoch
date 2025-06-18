-- epoch/ui/window/buffer/keymaps.lua
-- Buffer keymap management

local keymaps = {}

-- Setup keymaps for buffer
function keymaps.setup(buf, window_id, custom_keymaps)
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

return keymaps