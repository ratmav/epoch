-- minimal_init.lua for plenary test harness

-- add our plugin paths to the lua package path
local plugin_root = vim.fn.getcwd()

-- find plenary.nvim path regardless of plugin manager
local function find_plenary_path()
  -- common locations for plugins
  local plugin_paths = {
    vim.fn.stdpath('data') .. '/site/pack',
    vim.fn.stdpath('data') .. '/plugged',
    vim.fn.stdpath('config') .. '/pack',
    vim.fn.stdpath('config') .. '/plugged'
  }

  for _, base_path in ipairs(plugin_paths) do
    -- try to find plenary recursively in common plugin directories
    local plenary_path = vim.fn.glob(base_path .. '/**/plenary.nvim')
    if plenary_path ~= "" then
      -- return first match
      return plenary_path
    end
  end

  -- last resort: ask vim to find it in runtimepath
  local rtp_plenary = vim.fn.finddir('plenary.nvim', vim.o.runtimepath)
  if rtp_plenary ~= "" then
    return vim.fn.fnamemodify(rtp_plenary, ':p')
  end

  return ""
end

local plenary_root = find_plenary_path()

if plenary_root == "" then
  error("ERROR: could not find plenary.nvim.")
  vim.cmd('cquit 1')  -- exit with error code
end

-- add the plugin paths to package.path
package.path = string.format(
  '%s;%s;%s/lua/?.lua;%s/lua/?/init.lua',
  package.path,
  plugin_root .. '/lua/?.lua',
  plenary_root,
  plenary_root
)


-- Add plugin_root/tests to the package path for test modules and fixtures
package.path = package.path .. ';' .. plugin_root .. '/tests/?.lua;' ..
               plugin_root .. '/tests/?/init.lua;' .. plugin_root .. '/tests/helpers/?.lua'

-- minimal neovim configuration
vim.cmd([[
  filetype plugin indent on
  syntax enable
]])

-- set up a minimal data directory for tests
vim.opt.runtimepath:append(plenary_root)
vim.opt.runtimepath:append(plugin_root)


-- log the plenary path for debugging
print("using plenary.nvim from: " .. plenary_root)

-- Global fixture registry for all tests (after path setup)
_G.fixtures = require('fixtures.init')

-- return package path for debugging
return package.path