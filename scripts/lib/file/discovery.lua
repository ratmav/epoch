local discovery = {}

function discovery.get_lua_files()
    local files = {}
    local handle = io.popen('find lua/epoch -name "*.lua" -type f')
    for line in handle:lines() do
        table.insert(files, line)
    end
    handle:close()
    return files
end

return discovery