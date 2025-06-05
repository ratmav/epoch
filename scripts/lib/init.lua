local lib = {}

local file = require('file')
local template = require('template')
local status = require('status')

lib.get_lua_files = file.get_lua_files
lib.render_template = template.render
lib.determine_status = status.determine_status
lib.exit_with_status = status.exit_with_status

return lib