-- ui/window/buffer_spec.lua
-- Tests for buffer operations in floating windows

local buffer = require('epoch.ui.window.buffer')

describe('ui window buffer', function()
  after_each(function()
    -- Clean up test buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf):match("test%-") then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end)

  describe('create', function()
    it('should create buffer without name', function()
      local config = { filetype = "lua" }
      local buf = buffer.create(config)

      assert.is_true(vim.api.nvim_buf_is_valid(buf))
      assert.equals("", vim.api.nvim_buf_get_name(buf))
      assert.equals("lua", vim.api.nvim_buf_get_option(buf, 'filetype'))
    end)

    it('should create buffer with name', function()
      local config = {
        buffer_name = "test-named.lua",
        filetype = "lua"
      }

      local buf = buffer.create(config)
      assert.is_true(vim.api.nvim_buf_is_valid(buf))
      local expected_path = vim.fn.fnamemodify("test-named.lua", ":p")
      assert.equals(expected_path, vim.api.nvim_buf_get_name(buf))
      assert.equals("lua", vim.api.nvim_buf_get_option(buf, 'filetype'))
    end)

    it('should reuse existing buffer with same name', function()
      local config = { buffer_name = "test-reuse.lua" }

      local buf1 = buffer.create(config)
      local buf2 = buffer.create(config)

      -- This is the core test that would have caught the E95 error
      assert.equals(buf1, buf2)
    end)

    it('should create new buffer when previous buffer was deleted', function()
      local config = { buffer_name = "test-deleted.lua" }

      local buf1 = buffer.create(config)
      vim.api.nvim_buf_delete(buf1, { force = true })

      local buf2 = buffer.create(config)
      assert.is_true(vim.api.nvim_buf_is_valid(buf2))
      assert.not_equals(buf1, buf2)
    end)

    it('should set buffer options correctly', function()
      local config = {
        buffer_name = "test-options.lua",
        filetype = "markdown"
      }

      local buf = buffer.create(config)

      assert.equals("hide", vim.api.nvim_buf_get_option(buf, 'bufhidden'))
      assert.is_false(vim.api.nvim_buf_get_option(buf, 'swapfile'))
      assert.equals("markdown", vim.api.nvim_buf_get_option(buf, 'filetype'))
    end)

    it('should use default filetype when not specified', function()
      local config = { buffer_name = "test-default.lua" }

      local buf = buffer.create(config)
      assert.equals("text", vim.api.nvim_buf_get_option(buf, 'filetype'))
    end)
  end)

  describe('set_content', function()
    it('should set buffer content', function()
      local buf = buffer.create({ filetype = "lua" })
      local content = "line 1\nline 2\nline 3"

      buffer.set_content(buf, content)

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.same({"line 1", "line 2", "line 3"}, lines)
    end)

    it('should handle empty content', function()
      local buf = buffer.create({ filetype = "lua" })

      buffer.set_content(buf, "")

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.same({""}, lines)
    end)

    it('should set modifiable option correctly', function()
      local buf = buffer.create({ filetype = "lua" })

      -- Default should be modifiable
      buffer.set_content(buf, "test content")
      assert.is_true(vim.api.nvim_buf_get_option(buf, 'modifiable'))

      -- Explicitly set non-modifiable
      buffer.set_content(buf, "test content", false)
      assert.is_false(vim.api.nvim_buf_get_option(buf, 'modifiable'))
    end)
  end)

  describe('get_content', function()
    it('should get buffer content', function()
      local buf = buffer.create({ filetype = "lua" })
      local content = "line 1\nline 2"

      buffer.set_content(buf, content)
      local retrieved = buffer.get_content(buf)

      assert.equals(content, retrieved)
    end)

    it('should return nil for invalid buffer', function()
      local buf = buffer.create({ filetype = "lua" })
      vim.api.nvim_buf_delete(buf, { force = true })

      local content = buffer.get_content(buf)
      assert.is_nil(content)
    end)
  end)

  describe('update_content', function()
    it('should update buffer content', function()
      local buf = buffer.create({ filetype = "lua" })
      buffer.set_content(buf, "initial content")

      local success = buffer.update_content(buf, "updated content")

      assert.is_true(success)
      assert.equals("updated content", buffer.get_content(buf))
    end)

    it('should return false for invalid buffer', function()
      local buf = buffer.create({ filetype = "lua" })
      vim.api.nvim_buf_delete(buf, { force = true })

      local success = buffer.update_content(buf, "test")
      assert.is_false(success)
    end)

    it('should preserve modifiable state', function()
      local buf = buffer.create({ filetype = "lua" })
      buffer.set_content(buf, "initial", false) -- non-modifiable

      buffer.update_content(buf, "updated content")

      -- Should be non-modifiable again after update
      assert.is_false(vim.api.nvim_buf_get_option(buf, 'modifiable'))
      assert.is_false(vim.api.nvim_buf_get_option(buf, 'modified'))
    end)
  end)
end)
