#!/usr/bin/env lua

-- Test coverage checker for epoch project
-- Analyzes which Lua files have corresponding test files (1:1 mapping only)

local function get_lua_files()
    local files = {}
    local handle = io.popen('find lua/epoch -name "*.lua" -type f')
    for line in handle:lines() do
        table.insert(files, line)
    end
    handle:close()
    return files
end

local function get_test_files()
    local files = {}
    local handle = io.popen('find tests -name "*_spec.lua" -type f')
    for line in handle:lines() do
        table.insert(files, line)
    end
    handle:close()
    return files
end

local function has_no_test_comment(filepath)
    local file = io.open(filepath, 'r')
    if not file then
        return false
    end
    
    -- Check first 10 lines for the magic comment
    local line_count = 0
    for line in file:lines() do
        line_count = line_count + 1
        if line_count > 10 then
            break
        end
        
        -- Look for the magic comment pattern
        if line:match("^%s*%-%-%s*coverage:%s*no%s*tests?%s*$") then
            file:close()
            return true
        end
    end
    
    file:close()
    return false
end

local function calculate_test_coverage(lua_files, test_files)
    local coverage_stats = {
        total_files = #lua_files,
        testable_files = 0,
        tested_files = 0,
        untested_files = {},
        excluded_files = {},
        test_files = #test_files
    }
    
    -- Create a set of test file paths for exact 1:1 mapping
    local test_paths = {}
    for _, test_file in ipairs(test_files) do
        -- Convert test path to expected source path
        -- tests/storage/paths_spec.lua -> storage/paths
        local relative_test_path = test_file:match("tests/(.+)_spec%.lua$")
        if relative_test_path then
            test_paths[relative_test_path] = true
        end
    end
    
    -- Check each lua file for exact corresponding test
    for _, lua_file in ipairs(lua_files) do
        local relative_path = lua_file:match("lua/epoch/(.+)%.lua$")
        if relative_path then
            -- Check if file is marked as no-test
            if has_no_test_comment(lua_file) then
                table.insert(coverage_stats.excluded_files, lua_file)
            else
                coverage_stats.testable_files = coverage_stats.testable_files + 1
                
                -- Only check for exact 1:1 match
                if test_paths[relative_path] then
                    coverage_stats.tested_files = coverage_stats.tested_files + 1
                else
                    table.insert(coverage_stats.untested_files, lua_file)
                end
            end
        end
    end
    
    coverage_stats.coverage_percent = coverage_stats.testable_files > 0 and 
        (coverage_stats.tested_files / coverage_stats.testable_files) * 100 or 0
    return coverage_stats
end

local function check_coverage()
    local lua_files = get_lua_files()
    local test_files = get_test_files()
    local coverage_stats = calculate_test_coverage(lua_files, test_files)
    
    print("🧪 EPOCH TEST COVERAGE")
    print("=====================")
    print()
    
    printf("Test files found: %d", coverage_stats.test_files)
    printf("Total files: %d", coverage_stats.total_files)
    printf("Testable files: %d", coverage_stats.testable_files)
    printf("Files with tests: %d (%.1f%%)", 
           coverage_stats.tested_files, 
           coverage_stats.coverage_percent)
    printf("Files without tests: %d (%.1f%%)", 
           #coverage_stats.untested_files, 
           100 - coverage_stats.coverage_percent)
    if #coverage_stats.excluded_files > 0 then
        printf("Files excluded from testing: %d", #coverage_stats.excluded_files)
    end
    print()
    
    -- Show untested files if coverage is below 100%
    if coverage_stats.coverage_percent < 100 and #coverage_stats.untested_files > 0 then
        print("📋 UNTESTED FILES")
        print("=================")
        for _, file in ipairs(coverage_stats.untested_files) do
            -- Show what test file should exist
            local relative_path = file:match("lua/epoch/(.+)%.lua$")
            local expected_test = "tests/" .. relative_path .. "_spec.lua"
            printf("📄 %s (missing: %s)", file, expected_test)
        end
        print()
    end
    
    -- Show excluded files if any exist
    if #coverage_stats.excluded_files > 0 then
        print("🚫 FILES EXCLUDED FROM TESTING")
        print("==============================")
        for _, file in ipairs(coverage_stats.excluded_files) do
            printf("📄 %s", file)
        end
        print()
    end
    
    -- Summary
    local test_coverage_good = coverage_stats.coverage_percent >= 100
    local coverage_status = test_coverage_good and "✅ PASS" or "⚠️ WARN"
    
    print("🧪 COVERAGE SUMMARY")
    print("==================")
    printf("Test coverage: %s (%.1f%%)", coverage_status, coverage_stats.coverage_percent)
    
    -- Exit with appropriate code
    return test_coverage_good and 0 or 1
end

-- Helper function for formatted printing
function printf(fmt, ...)
    print(string.format(fmt, ...))
end

-- Run the check
local exit_code = check_coverage()
os.exit(exit_code)