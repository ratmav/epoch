-- tests/commands/register_spec.lua

local register = require('epoch.commands.register')

describe('commands register', function()
  describe('register', function()
    it('should register commands without error', function()
      assert.has_no.errors(function()
        register.register()
      end)
    end)

    it('should create EpochEdit command', function()
      register.register()
      local command_exists = vim.api.nvim_get_commands({})['EpochEdit'] ~= nil
      assert.is_true(command_exists)
    end)

    it('should create EpochEdit command with optional date parameter', function()
      register.register()
      local command_info = vim.api.nvim_get_commands({})['EpochEdit']
      assert.is_not_nil(command_info)
      assert.equals('?', command_info.nargs)
    end)

    it('should create EpochInterval command', function()
      register.register()
      local command_exists = vim.api.nvim_get_commands({})['EpochInterval'] ~= nil
      assert.is_true(command_exists)
    end)

    it('should create EpochReport command', function()
      register.register()
      local command_exists = vim.api.nvim_get_commands({})['EpochReport'] ~= nil
      assert.is_true(command_exists)
    end)

    it('should create EpochClear command', function()
      register.register()
      local command_exists = vim.api.nvim_get_commands({})['EpochClear'] ~= nil
      assert.is_true(command_exists)
    end)
  end)
end)