-- config_spec.lua
-- Tests for epoch configuration module

local config = require('epoch.config')
local storage = require('epoch.storage')

describe('config', function()
  before_each(function()
    -- Reset config to defaults before each test
    config.values = {
      data_dir = vim.fn.stdpath('data') .. '/epoch',
      ui = {
        window_width_pct = 0.4,
        window_height_pct = 0.7,
        border = 'rounded'
      }
    }
  end)

  describe('get', function()
    it('should return config values for existing keys', function()
      local data_dir = config.get('data_dir')
      assert.equals(vim.fn.stdpath('data') .. '/epoch', data_dir)
    end)

    it('should return ui config values', function()
      local ui_config = config.get('ui')
      assert.equals(0.4, ui_config.window_width_pct)
      assert.equals(0.7, ui_config.window_height_pct)
      assert.equals('rounded', ui_config.border)
    end)

    it('should return nil for non-existent keys', function()
      local non_existent = config.get('non_existent_key')
      assert.is_nil(non_existent)
    end)
  end)

  describe('setup', function()
    it('should merge user options with defaults', function()
      local temp_dir = vim.fn.tempname()
      local user_opts = {
        data_dir = temp_dir,
        ui = {
          window_width_pct = 0.6
        }
      }

      config.setup(user_opts)

      assert.equals(temp_dir, config.get('data_dir'))
      assert.equals(0.6, config.get('ui').window_width_pct)
      -- Should preserve default values not overridden
      assert.equals(0.7, config.get('ui').window_height_pct)
      assert.equals('rounded', config.get('ui').border)
    end)

    it('should use defaults when no options provided', function()
      config.setup()

      assert.equals(vim.fn.stdpath('data') .. '/epoch', config.get('data_dir'))
      assert.equals(0.4, config.get('ui').window_width_pct)
    end)

    it('should handle empty options table', function()
      config.setup({})

      assert.equals(vim.fn.stdpath('data') .. '/epoch', config.get('data_dir'))
      assert.equals(0.4, config.get('ui').window_width_pct)
    end)

    it('should set data directory in storage module', function()
      local temp_dir = vim.fn.tempname()

      config.setup({ data_dir = temp_dir })

      -- Verify storage module received the data directory
      assert.equals(temp_dir, storage.get_data_dir())
    end)
  end)
end)