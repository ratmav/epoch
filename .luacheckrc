-- Luacheck configuration for epoch Neovim plugin

-- Neovim globals
globals = {
  "vim"
}

-- Test-specific configuration
files["tests/"] = {
  globals = {
    "describe", "it", "assert", "fixtures"
  }
}