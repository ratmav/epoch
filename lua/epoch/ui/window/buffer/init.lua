-- epoch/ui/window/buffer/init.lua
-- Buffer operations for floating windows (delegates to focused modules)
-- coverage: no tests

local buffer = {}

-- Import focused modules
local lifecycle = require('epoch.ui.window.buffer.lifecycle')
local content = require('epoch.ui.window.buffer.content')
local keymaps = require('epoch.ui.window.buffer.keymaps')

-- Delegate to lifecycle module
function buffer.create(config)
  return lifecycle.create(config)
end

-- Delegate to content module
function buffer.set_content(buf, content_text, modifiable)
  return content.set(buf, content_text, modifiable)
end

function buffer.get_content(buf)
  return content.get(buf)
end

function buffer.update_content(buf, content_text)
  return content.update(buf, content_text)
end

-- Delegate to keymaps module
function buffer.setup_keymaps(buf, window_id, custom_keymaps)
  return keymaps.setup(buf, window_id, custom_keymaps)
end

return buffer