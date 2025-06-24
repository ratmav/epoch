-- laconic/compliance.lua
-- Laconic compliance checking for SRP violations

local function_analyzer = require('laconic.analyzer.function')
local file_analyzer = require('laconic.analyzer.file')
local discovery = require('laconic.discovery')

local compliance = {}

function compliance.check_file_length(file)
    local lines = file_analyzer.count_lines(file)
    if lines > 100 then
        return {file=file, lines=lines}
    end
    return nil
end

function compliance.check_file_functions(file)
    local violations = {}
    local functions = function_analyzer.extract_functions(file)

    for _, func in ipairs(functions) do
        if func.lines > 15 then
            table.insert(violations, {file=file, name=func.name, lines=func.lines})
        end
    end

    return functions, violations
end

function compliance.process_file_length(file, long_files)
    local file_violation = compliance.check_file_length(file)
    if file_violation then
        table.insert(long_files, file_violation)
    end
end

function compliance.process_file_functions(file, long_functions)
    local functions, function_violations = compliance.check_file_functions(file)

    for _, violation in ipairs(function_violations) do
        table.insert(long_functions, violation)
    end

    return #functions
end

function compliance.analyze_files(files)
    local long_files, long_functions = {}, {}
    local total_files, total_functions = 0, 0

    for _, file in ipairs(files) do
        total_files = total_files + 1

        compliance.process_file_length(file, long_files)
        local function_count = compliance.process_file_functions(file, long_functions)
        total_functions = total_functions + function_count
    end

    return total_files, total_functions, long_files, long_functions
end

function compliance.check_directory(path)
    local files = discovery.find_lua_files(path)
    local total_files, total_functions, long_files, long_functions = compliance.analyze_files(files)

    return {
        total_files = total_files,
        total_functions = total_functions,
        long_files = long_files,
        long_functions = long_functions,
        compliant = #long_files == 0 and #long_functions == 0
    }
end

return compliance
