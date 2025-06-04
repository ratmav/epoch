-- epoch/ui/window/highlights.lua
-- Highlight management for floating windows
-- coverage: no tests

local highlights = {}

-- Set up highlight groups based on current colorscheme
function highlights.setup()
  local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
  local normal_fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg

  local highlight_groups = {
    EpochNormal = { default = true, bg = normal_bg, fg = normal_fg },
    EpochBorder = { default = true, bg = normal_bg, fg = normal_fg },
    EpochTitle = { default = true, bg = normal_bg, fg = normal_fg, bold = true },
  }

  for k, v in pairs(highlight_groups) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

-- Setup colorscheme change listener
function highlights.setup_autocmd()
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = highlights.setup,
    group = vim.api.nvim_create_augroup("EpochWindowHighlights", { clear = true }),
  })
end

return highlights