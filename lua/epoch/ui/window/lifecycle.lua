-- epoch/ui/window/lifecycle.lua
-- Window creation and destruction lifecycle
-- coverage: no tests

local creation = require("epoch.ui.window.creation")
local cleanup = require("epoch.ui.window.cleanup")

local lifecycle = {}

-- Create a floating window with calculated dimensions
function lifecycle.create_window(buf, config)
  return creation.create_window(buf, config)
end

-- Close and clean up a specific window
function lifecycle.close_window(window_id)
  cleanup.close_window(window_id)
end

-- Setup QuitPre autocmd for save handling
function lifecycle.setup_quit_handler()
  cleanup.setup_quit_handler()
end

return lifecycle