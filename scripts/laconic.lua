#!/usr/bin/env lua

-- Laconic CLI wrapper - thin interface to laconic module
-- Detects Single Responsibility Principle violations

-- Set up Lua path for the laconic module
package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local laconic = require('laconic')
local lib = require('init')

local function build_file_violations(long_files)
    local list = {}
    for _, violation in ipairs(long_files) do
        table.insert(list, {
            file = violation.file,
            lines = violation.lines
        })
    end
    return list
end

local function build_function_violations(long_functions)
    local list = {}
    for _, violation in ipairs(long_functions) do
        table.insert(list, {
            file = violation.file,
            function_name = violation.name,
            lines = violation.lines
        })
    end
    return list
end

local function build_template_data(results)
    local data = {
        total_files = results.total_files,
        files_over_100 = #results.long_files,
        total_functions = results.total_functions,
        functions_over_15 = #results.long_functions,
        has_long_files = #results.long_files > 0,
        has_long_functions = #results.long_functions > 0
    }

    if data.has_long_files then
        data.long_files_list = build_file_violations(results.long_files)
    end

    if data.has_long_functions then
        data.long_functions_list = build_function_violations(results.long_functions)
    end

    return data
end

local function add_status_fields(template_data, results)
    local file_compliant = #results.long_files == 0
    local function_compliant = #results.long_functions == 0

    template_data.file_status = file_compliant and "✅ PASS" or "❌ FAIL"
    template_data.function_status = function_compliant and "✅ PASS" or "❌ FAIL"
    template_data.overall_status = results.compliant and "✅ PASS" or "❌ FAIL"
end

local function print_report(results)
    local template_data = build_template_data(results)
    add_status_fields(template_data, results)

    local report = lib.render_template('laconic_report.template', template_data)
    print(report)
end

-- Main execution
local path = ... or "lua/epoch"
local results = laconic.check_directory(path)
print_report(results)
lib.exit_with_status(results.compliant)
