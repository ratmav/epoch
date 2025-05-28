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
        local func_name = nil
        local is_function_line = false
        
        -- Pattern 1: function module.name(...)
        func_name = line:match("^%s*function%s+([%w_.]+)%s*%(")
        if func_name then
            is_function_line = true
        end
        
        -- Pattern 2: local function name(...)
        if not func_name then
            func_name = line:match("^%s*local%s+function%s+([%w_]+)%s*%(")
            if func_name then
                is_function_line = true
            end
        end
        
        -- Pattern 3: name = function(...)
        if not func_name then
            func_name = line:match("^%s*([%w_.]+)%s*=%s*function%s*%(")
            if func_name then
                is_function_line = true
            end
        end
        
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
                    for word in trimmed_current:gmatch("%f[%w_]function%f[%W]") do
                        depth = depth + 1
                    end
                    for word in trimmed_current:gmatch("%f[%w_]if%f[%W]") do
                        depth = depth + 1
                    end
                    for word in trimmed_current:gmatch("%f[%w_]for%f[%W]") do
                        depth = depth + 1
                    end
                    for word in trimmed_current:gmatch("%f[%w_]while%f[%W]") do
                        depth = depth + 1
                    end
                    for word in trimmed_current:gmatch("%f[%w_]repeat%f[%W]") do
                        depth = depth + 1
                    end
                    for word in trimmed_current:gmatch("%f[%w_]do%f[%W]") do
                        -- Only count 'do' if it's not part of a function parameter list
                        if not trimmed_current:match("function.*do") then
                            depth = depth + 1
                        end
                    end
                    
                    -- Count block-ending keywords
                    for word in trimmed_current:gmatch("%f[%w_]end%f[%W]") do
                        depth = depth - 1
                    end
                    for word in trimmed_current:gmatch("%f[%w_]until%f[%W]") do
                        depth = depth - 1
                    end
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