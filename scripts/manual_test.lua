#!/usr/bin/env lua

local template = require('template')

local function get_current_date()
    return os.date('%Y-%m-%d')
end

local function generate_manual_test_file()
    local current_date = get_current_date()
    local output_filename = 'manual_test_' .. current_date .. '.md'

    local data = {
        date = current_date
    }

    local content = template.render('manual_test.template', data)

    local file = io.open(output_filename, 'w')
    if not file then
        error('Failed to create file: ' .. output_filename)
    end

    file:write(content)
    file:close()

    print('Generated manual test file: ' .. output_filename)
end

generate_manual_test_file()
