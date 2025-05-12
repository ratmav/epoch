-- epoch/ui/window/config.lua
-- Window configuration utilities
-- coverage: no tests

local window_config = {}

-- Set default configuration values
function window_config.set_defaults(config)
  local width_pct = config.width_percent or 0.5
  local height_pct = config.height_percent or 0.6
  local title = config.title or "epoch"
  return width_pct, height_pct, title
end

-- Calculate window dimensions based on percentages
function window_config.calculate_dimensions(width_pct, height_pct)
  local width = math.floor(vim.o.columns * width_pct)
  local height = math.floor(vim.o.lines * height_pct)
  return width, height
end

return window_config