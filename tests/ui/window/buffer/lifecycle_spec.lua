-- ui/window/buffer/lifecycle_spec.lua
-- Tests for buffer lifecycle functions

local lifecycle = require('epoch.ui.window.buffer.lifecycle')

describe('ui window buffer lifecycle', function()
  after_each(function()
    -- Clean up test buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf):match("test%-lifecycle") then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end)

  describe('create', function()
    it('should call lifecycle.create function', function()
      local config = { buffer_name = "test-lifecycle-create.lua", filetype = "lua" }

      local buf = lifecycle.create(config)

      assert.is_number(buf)
      assert.is_true(vim.api.nvim_buf_is_valid(buf))
    end)
  end)
end)
