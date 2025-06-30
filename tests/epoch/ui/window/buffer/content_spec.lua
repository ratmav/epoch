-- ui/window/buffer/content_spec.lua
-- Tests for buffer content functions

local content = require('epoch.ui.window.buffer.content')

describe('ui window buffer content', function()
  local test_buf

  before_each(function()
    test_buf = vim.api.nvim_create_buf(false, false)
  end)

  after_each(function()
    if vim.api.nvim_buf_is_valid(test_buf) then
      vim.api.nvim_buf_delete(test_buf, { force = true })
    end
  end)

  describe('set', function()
    it('should call content.set function', function()
      content.set(test_buf, "test content", true)

      local lines = vim.api.nvim_buf_get_lines(test_buf, 0, -1, false)
      assert.same({"test content"}, lines)
    end)
  end)

  describe('get', function()
    it('should call content.get function', function()
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, {"line 1", "line 2"})

      local result = content.get(test_buf)

      assert.equals("line 1\nline 2", result)
    end)
  end)

  describe('update', function()
    it('should call content.update function', function()
      vim.api.nvim_buf_set_lines(test_buf, 0, -1, false, {"initial"})

      local success = content.update(test_buf, "updated")

      assert.is_true(success)
    end)
  end)
end)
