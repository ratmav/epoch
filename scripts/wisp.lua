#!/usr/bin/env lua

-- Whitespace cleaner for epoch project
-- Removes trailing whitespace and empty lines with whitespace


local function clean_file(filepath)
    local file = io.open(filepath, 'r')
    if not file then
        return false, 'Could not open file: ' .. filepath
    end

    local lines = {}
    local changes_made = false

    for line in file:lines() do
        local original_line = line
        -- Remove trailing whitespace
        line = line:gsub('%s+$', '')

        if original_line ~= line then
            changes_made = true
        end

        table.insert(lines, line)
    end
    file:close()

    if changes_made then
        local output_file = io.open(filepath, 'w')
        if not output_file then
            return false, 'Could not write to file: ' .. filepath
        end

        for _, line in ipairs(lines) do
            output_file:write(line .. '\n')
        end
        output_file:close()

        return true, 'Cleaned whitespace in: ' .. filepath
    end

    return false, 'No changes needed: ' .. filepath
end

local function get_lua_files(directory)
    local files = {}
    local handle = io.popen('find "' .. directory .. '" -name "*.lua" -type f')
    if handle then
        for line in handle:lines() do
            table.insert(files, line)
        end
        handle:close()
    end
    return files
end

local function main(args)
    local target_dir = args[1] or '.'

    print('🧹 EPOCH WHITESPACE CLEANER')
    print('===========================')
    print('')

    local lua_files = get_lua_files(target_dir)
    local cleaned_count = 0
    local total_count = #lua_files

    for _, filepath in ipairs(lua_files) do
        local success, message = clean_file(filepath)
        if success then
            print('✅ ' .. message)
            cleaned_count = cleaned_count + 1
        end
    end

    print('')
    print('🧹 WHITESPACE CLEANUP SUMMARY')
    print('=============================')
    print('Files processed: ' .. total_count)
    print('Files cleaned: ' .. cleaned_count)
    print('Files unchanged: ' .. (total_count - cleaned_count))

    if cleaned_count > 0 then
        print('')
        print('✅ Whitespace cleanup complete!')
    else
        print('')
        print('✨ All files already clean!')
    end
end

main(arg)
