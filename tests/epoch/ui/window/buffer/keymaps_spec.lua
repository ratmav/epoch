-- ui/window/buffer/keymaps_spec.lua
-- Tests for buffer keymap functions

local keymaps = require('epoch.ui.window.buffer.keymaps')

describe('ui window buffer keymaps', function()
  local test_buf

  before_each(function()
    test_buf = vim.api.nvim_create_buf(false, false)
  end)

  after_each(function()
    if vim.api.nvim_buf_is_valid(test_buf) then
      vim.api.nvim_buf_delete(test_buf, { force = true })
    end
  end)

  describe('setup', function()
    it('should call keymaps.setup function', function()
      assert.has_no.errors(function()
        keymaps.setup(test_buf, "test_window", {})
      end)
    end)

    it('should set default keymaps', function()
      keymaps.setup(test_buf, "test_window", {})

      local maps = vim.api.nvim_buf_get_keymap(test_buf, 'n')
      local q_map = nil
      local esc_map = nil

      for _, map in ipairs(maps) do
        if map.lhs == 'q' then q_map = map end
        if map.lhs == '<Esc>' then esc_map = map end
      end

      assert.is_not_nil(q_map)
      assert.is_not_nil(esc_map)
    end)
  end)
end)
