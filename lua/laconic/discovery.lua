-- laconic/discovery.lua
-- File discovery utilities

local discovery = {}

function discovery.find_lua_files(path)
    local files = {}
    local handle = io.popen('find "' .. path .. '" -name "*.lua" -type f')
    for line in handle:lines() do
        table.insert(files, line)
    end
    handle:close()
    return files
end

return discovery