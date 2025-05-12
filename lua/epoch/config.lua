-- epoch/config.lua
-- configuration for epoch time tracking

local config = {}

local defaults = {
  data_dir = vim.fn.stdpath('data') .. '/epoch',
  ui = {
    window_width = 60,
    window_height = 20,
    border = 'rounded'
  }
}

config.values = vim.deepcopy(defaults)

-- setup function to initialize the plugin
function config.setup(opts)
  config.values = vim.tbl_deep_extend('force', defaults, opts or {})
  
  -- create data directory if it doesn't exist
  vim.fn.mkdir(config.values.data_dir, 'p')
end

return config