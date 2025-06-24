-- laconic/analyzer/file.lua
-- File length analysis

local file_analyzer = {}

function file_analyzer.count_lines(filepath)
    local count = 0
    local file = io.open(filepath, 'r')
    if not file then
        return 0
    end

    for _ in file:lines() do
        count = count + 1
    end
    file:close()
    return count
end

return file_analyzer