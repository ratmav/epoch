#!/usr/bin/env lua

-- Compliance checker for epoch project
-- Checks file length and function length compliance

local function get_lua_files()
    local files = {}
    local handle = io.popen('find lua/epoch -name "*.lua" -type f')
    for line in handle:lines() do
        table.insert(files, line)
    end
    handle:close()
    return files
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

local function extract_functions(filepath)
    local functions = {}
    local file = io.open(filepath, 'r')
    if not file then
        return functions
    end
    
    local content = file:read('*all')
    file:close()
    
    -- Find function definitions and count their lines
    local line_num = 0
    local in_function = nil
    local function_start = 0
    local brace_count = 0
    
    for line in content:gmatch("[^\n]*") do
        line_num = line_num + 1
        
        -- Check for function definition
        local func_name = line:match("function%s+([%w_.]+)%s*%(")
        if not func_name then
            func_name = line:match("local%s+function%s+([%w_]+)%s*%(")
        end
        if not func_name then
            func_name = line:match("([%w_.]+)%s*=%s*function%s*%(")
        end
        
        if func_name and not in_function then
            in_function = func_name
            function_start = line_num
            brace_count = 0
        end
        
        if in_function then
            -- Count braces/blocks to find function end
            -- This is a simplified approach - counts 'end' keywords
            local ends = 0
            local starts = 0
            
            for _ in line:gmatch("function") do starts = starts + 1 end
            for _ in line:gmatch("if") do starts = starts + 1 end
            for _ in line:gmatch("for") do starts = starts + 1 end
            for _ in line:gmatch("while") do starts = starts + 1 end
            for _ in line:gmatch("repeat") do starts = starts + 1 end
            for _ in line:gmatch("do") do starts = starts + 1 end
            
            for _ in line:gmatch("end") do ends = ends + 1 end
            for _ in line:gmatch("until") do ends = ends + 1 end
            
            brace_count = brace_count + starts - ends
            
            -- Function ends when brace count returns to 0 (but not on the function line itself)
            if brace_count <= 0 and line_num > function_start then
                local func_lines = line_num - function_start + 1
                table.insert(functions, {
                    name = in_function,
                    lines = func_lines,
                    start_line = function_start
                })
                in_function = nil
            end
        end
    end
    
    return functions
end

local function check_compliance()
    local files = get_lua_files()
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
    
    print("🔍 EPOCH COMPLIANCE CHECK")
    print("========================")
    print()
    
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
    
    -- Print statistics
    print("📊 STATISTICS")
    print("=============")
    printf("Total files analyzed: %d", stats.total_files)
    printf("Files under 100 lines: %d (%.1f%%)", 
           stats.files_under_100, 
           (stats.files_under_100 / stats.total_files) * 100)
    printf("Files 100-150 lines: %d (%.1f%%)", 
           stats.files_100_150, 
           (stats.files_100_150 / stats.total_files) * 100)
    printf("Files over 150 lines: %d (%.1f%%)", 
           stats.files_over_150, 
           (stats.files_over_150 / stats.total_files) * 100)
    print()
    printf("Total functions analyzed: %d", stats.total_functions)
    printf("Functions under 15 lines: %d (%.1f%%)", 
           stats.functions_under_15, 
           (stats.functions_under_15 / stats.total_functions) * 100)
    printf("Functions over 15 lines: %d (%.1f%%)", 
           stats.functions_over_15, 
           (stats.functions_over_15 / stats.total_functions) * 100)
    print()
    
    -- Print violations
    if #violations.file_length > 0 then
        print("❌ FILE LENGTH VIOLATIONS")
        print("=========================")
        for _, violation in ipairs(violations.file_length) do
            local icon = violation.severity == "CRITICAL" and "🔴" or "🟡"
            printf("%s %s - %d lines (%s)", 
                   icon, violation.file, violation.lines, violation.severity)
        end
        print()
    end
    
    if #violations.function_length > 0 then
        print("❌ FUNCTION LENGTH VIOLATIONS")
        print("=============================")
        for _, violation in ipairs(violations.function_length) do
            printf("🔴 %s:%d - %s() - %d lines", 
                   violation.file, violation.start_line, violation.name, violation.lines)
        end
        print()
    end
    
    -- Summary
    local file_compliant = stats.files_over_150 == 0
    local function_compliant = stats.functions_over_15 == 0
    local fully_compliant = file_compliant and function_compliant
    
    print("🎯 COMPLIANCE SUMMARY")
    print("====================")
    printf("File length compliance: %s", file_compliant and "✅ PASS" or "❌ FAIL")
    printf("Function length compliance: %s", function_compliant and "✅ PASS" or "❌ FAIL")
    printf("Overall compliance: %s", fully_compliant and "✅ PASS" or "❌ FAIL")
    
    -- Exit with appropriate code
    return fully_compliant and 0 or 1
end

-- Helper function for formatted printing
function printf(fmt, ...)
    print(string.format(fmt, ...))
end

-- Run the check
local exit_code = check_compliance()
os.exit(exit_code)