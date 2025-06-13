-- commands_spec.lua
-- Tests for epoch commands module

local commands = require('epoch.commands')

describe('commands', function()
  describe('register', function()
    it('should register commands without error', function()
      -- Test that register function can be called without throwing errors
      assert.has_no.errors(function()
        commands.register()
      end)
    end)

    it('should create EpochEdit command', function()
      commands.register()

      -- Check that the command exists
      local command_exists = vim.api.nvim_get_commands({})['EpochEdit'] ~= nil
      assert.is_true(command_exists)
    end)

    it('should create EpochEdit command with optional date parameter', function()
      commands.register()

      -- Check that the command accepts arguments
      local command_info = vim.api.nvim_get_commands({})['EpochEdit']
      assert.is_not_nil(command_info)
      assert.equals('?', command_info.nargs)
    end)

    it('should create EpochInterval command', function()
      commands.register()

      -- Check that the command exists
      local command_exists = vim.api.nvim_get_commands({})['EpochInterval'] ~= nil
      assert.is_true(command_exists)
    end)

    it('should create EpochReport command', function()
      commands.register()

      -- Check that the command exists
      local command_exists = vim.api.nvim_get_commands({})['EpochReport'] ~= nil
      assert.is_true(command_exists)
    end)

    it('should create EpochClear command', function()
      commands.register()

      -- Check that the command exists
      local command_exists = vim.api.nvim_get_commands({})['EpochClear'] ~= nil
      assert.is_true(command_exists)
    end)
  end)
end)