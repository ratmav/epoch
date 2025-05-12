#!/usr/bin/env lua

-- Laconic compliance checker for epoch project
-- Checks file length and function length compliance only

local lib = require('init')

local function path_exists(path)
    -- Check if it's a directory first
    local result = os.execute('test -d "' .. path .. '"')
    if result == 0 then
        return true, 'directory'
    end

    -- Then check if it's a file
    local file = io.open(path, 'r')
    if file then
        file:close()
        return true, 'file'
    end

    return false, nil
end

local function validate_path(path)
    if not path then
        error("Path argument is required")
    end

    local exists, type = path_exists(path)
    if not exists then
        error("Path does not exist: " .. path)
    end

    return type
end

local function find_lua_files(path)
    local files = {}
    local handle = io.popen('find "' .. path .. '" -name "*.lua" -type f')
    for line in handle:lines() do
        table.insert(files, line)
    end
    handle:close()
    return files
end

local function get_lua_files(path)
    local path_type = validate_path(path)

    if path_type == 'file' then
        if path:match('%.lua$') then
            return {path}
        else
            error("File is not a Lua file: " .. path)
        end
    end

    return find_lua_files(path)
end

local function count_lines(filepath)
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

-- More reliable function extraction using careful parsing
local function extract_functions(filepath)
    local functions = {}
    local file = io.open(filepath, 'r')
    if not file then
        return functions
    end

    local lines = {}
    for line in file:lines() do
        table.insert(lines, line)
    end
    file:close()

    local i = 1
    while i <= #lines do
        local line = lines[i]

        -- Skip comments and empty lines
        local trimmed = line:match("^%s*(.-)%s*$")
        if not (trimmed:match("^%-%-") or trimmed == "") then

        -- Check for function definition patterns
        local function extract_function_name(code_line)
            return code_line:match("^%s*function%s+([%w_.]+)%s*%(") or
                   code_line:match("^%s*local%s+function%s+([%w_]+)%s*%(") or
                   code_line:match("^%s*([%w_.]+)%s*=%s*function%s*%(")
        end

        local func_name = extract_function_name(line)
        local is_function_line = func_name ~= nil

        if is_function_line and func_name then
            local function_start = i
            local depth = 1  -- We're inside the function now
            local j = i + 1

            -- Find the matching 'end' for this function
            while j <= #lines and depth > 0 do
                local current_line = lines[j]
                local trimmed_current = current_line:match("^%s*(.-)%s*$")

                -- Skip comments
                if not trimmed_current:match("^%-%-") then
                    -- Count block-starting keywords
                    local _, function_count = trimmed_current:gsub("%f[%w_]function%f[%W]", "")
                    local _, if_count = trimmed_current:gsub("%f[%w_]if%f[%W]", "")
                    local _, for_count = trimmed_current:gsub("%f[%w_]for%f[%W]", "")
                    local _, while_count = trimmed_current:gsub("%f[%w_]while%f[%W]", "")
                    local _, repeat_count = trimmed_current:gsub("%f[%w_]repeat%f[%W]", "")

                    local do_count = 0
                    if not trimmed_current:match("function.*do") then
                        _, do_count = trimmed_current:gsub("%f[%w_]do%f[%W]", "")
                    end

                    depth = depth + function_count + if_count + for_count + while_count + repeat_count + do_count

                    -- Count block-ending keywords
                    local _, end_count = trimmed_current:gsub("%f[%w_]end%f[%W]", "")
                    local _, until_count = trimmed_current:gsub("%f[%w_]until%f[%W]", "")

                    depth = depth - end_count - until_count
                end

                j = j + 1
            end

            -- If we found the end, record the function
            if depth == 0 then
                local func_lines = j - function_start
                table.insert(functions, {
                    name = func_name,
                    lines = func_lines,
                    start_line = function_start
                })
                i = j - 1  -- Continue from after this function
            else
                -- Couldn't find matching end, skip this
                i = i + 1
            end
        end

        end -- end of if not comment/empty
        i = i + 1
    end

    return functions
end

local function check_compliance(path)
    local files = get_lua_files(path)
    local violations = {
        file_length = {},
        function_length = {}
    }
    local stats = {
        total_files = 0,
        files_under_100 = 0,
        files_100_150 = 0,
        files_over_150 = 0,
        total_functions = 0,
        functions_under_15 = 0,
        functions_over_15 = 0
    }

    for _, filepath in ipairs(files) do
        local line_count = count_lines(filepath)
        stats.total_files = stats.total_files + 1

        -- File length compliance
        if line_count > 150 then
            table.insert(violations.file_length, {
                file = filepath,
                lines = line_count,
                severity = "CRITICAL"
            })
            stats.files_over_150 = stats.files_over_150 + 1
        elseif line_count > 100 then
            table.insert(violations.file_length, {
                file = filepath,
                lines = line_count,
                severity = "WARNING"
            })
            stats.files_100_150 = stats.files_100_150 + 1
        else
            stats.files_under_100 = stats.files_under_100 + 1
        end

        -- Function length compliance
        local functions = extract_functions(filepath)
        for _, func in ipairs(functions) do
            stats.total_functions = stats.total_functions + 1

            if func.lines > 15 then
                table.insert(violations.function_length, {
                    file = filepath,
                    name = func.name,
                    lines = func.lines,
                    start_line = func.start_line
                })
                stats.functions_over_15 = stats.functions_over_15 + 1
            else
                stats.functions_under_15 = stats.functions_under_15 + 1
            end
        end
    end

    -- Prepare template data
    local template_data = {
        total_files = stats.total_files,
        files_under_100 = stats.files_under_100,
        files_under_100_percent = string.format("%.1f", (stats.files_under_100 / stats.total_files) * 100),
        files_100_150 = stats.files_100_150,
        files_100_150_percent = string.format("%.1f", (stats.files_100_150 / stats.total_files) * 100),
        files_over_150 = stats.files_over_150,
        files_over_150_percent = string.format("%.1f", (stats.files_over_150 / stats.total_files) * 100),
        total_functions = stats.total_functions,
        functions_under_15 = stats.functions_under_15,
        functions_under_15_percent = string.format("%.1f", (stats.functions_under_15 / stats.total_functions) * 100),
        functions_over_15 = stats.functions_over_15,
        functions_over_15_percent = string.format("%.1f", (stats.functions_over_15 / stats.total_functions) * 100),
        has_long_files = #violations.file_length > 0,
        has_long_functions = #violations.function_length > 0
    }

    -- Prepare long files list
    if template_data.has_long_files then
        template_data.long_files_list = {}
        for _, violation in ipairs(violations.file_length) do
            local icon = violation.severity == "CRITICAL" and "🔴" or "🟡"
            table.insert(template_data.long_files_list, {
                status = icon,
                file = violation.file,
                lines = violation.lines,
                compliance = violation.severity
            })
        end
    end

    -- Prepare long functions list
    if template_data.has_long_functions then
        template_data.long_functions_list = {}
        for _, violation in ipairs(violations.function_length) do
            table.insert(template_data.long_functions_list, {
                file = violation.file,
                line_number = violation.start_line,
                function_name = violation.name,
                lines = violation.lines
            })
        end
    end

    -- Summary status
    local file_compliant = stats.files_over_150 == 0
    local file_has_warnings = stats.files_100_150 > 0
    local function_compliant = stats.functions_over_15 == 0
    local fully_compliant = file_compliant and function_compliant

    template_data.file_status = file_compliant and (file_has_warnings and "⚠️ WARN" or "✅ PASS") or "❌ FAIL"
    template_data.function_status = function_compliant and "✅ PASS" or "❌ FAIL"
    template_data.overall_status = fully_compliant and (file_has_warnings and "⚠️ WARN" or "✅ PASS") or "❌ FAIL"

    -- Render and print report
    local report = lib.render_template('laconic_report.template', template_data)
    print(report)

    -- Exit with appropriate code
    return fully_compliant and 0 or 1
end

-- Check if path argument is provided
local path = ...
if not path then
    print("Error: Path argument is required")
    print("Usage: lua laconic.lua <path>")
    os.exit(1)
end

-- Run the check
local exit_code = check_compliance(path)
os.exit(exit_code)
