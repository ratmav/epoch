-- epoch/config.lua
-- configuration for epoch time tracking
-- coverage: no tests

local config = {}

local defaults = {
  data_dir = vim.fn.stdpath('data') .. '/epoch',
  ui = {
    window_width_pct = 0.4,  -- 40% of screen width
    window_height_pct = 0.7, -- 70% of screen height
    border = 'rounded'
  }
}

config.values = vim.deepcopy(defaults)

-- setup function to initialize the plugin
function config.setup(opts)
  config.values = vim.tbl_deep_extend('force', defaults, opts or {})

  -- ensure data directory exists
  vim.fn.mkdir(config.values.data_dir, 'p')

  -- set the data directory in storage module
  require('epoch.storage').set_data_dir(config.values.data_dir)
end

-- get the config value for a specific key
function config.get(key)
  return config.values[key]
end

return config