-- laconic/analyzer/function.lua
-- AST-based function detection and analysis

local function_analyzer = {}

function function_analyzer.create_stub_environment()
    return {
        require = function(_)
            return setmetatable({}, {__index = function() return function() end end})
        end,
        vim = setmetatable({}, {
            __index = function()
                return setmetatable({}, {__index = function() return function() end end})
            end
        }),
        print = print, pairs = pairs, ipairs = ipairs, type = type,
        string = string, table = table, math = math, os = os, io = io
    }
end

function function_analyzer.parse_file_content(filepath)
    local file = io.open(filepath, 'r')
    if not file then
        return nil, "Could not open file"
    end

    local content = file:read("*all")
    file:close()

    local chunk = loadstring and loadstring(content, filepath) or load(content, filepath)
    return chunk
end

function function_analyzer.execute_in_stub_env(chunk, stub_env)
    if setfenv then  -- Lua 5.1
        setfenv(chunk, stub_env)
    end

    local success, module_result = pcall(chunk)
    return success, module_result
end

function function_analyzer.create_function_entry(name, info)
    local lines = info.lastlinedefined - info.linedefined + 1
    return {
        name = name,
        lines = lines,
        start_line = info.linedefined
    }
end

function function_analyzer.process_function(name, func)
    local info = debug.getinfo(func, 'S')
    if info and info.linedefined > 0 and info.lastlinedefined > 0 then
        return function_analyzer.create_function_entry(name, info)
    end
    return nil
end

function function_analyzer.collect_functions_from_table(module_result)
    local functions = {}

    for name, func in pairs(module_result) do
        if type(func) == 'function' then
            local func_entry = function_analyzer.process_function(name, func)
            if func_entry then
                table.insert(functions, func_entry)
            end
        end
    end

    return functions
end

function function_analyzer.extract_function_info(module_result)
    if type(module_result) == 'table' then
        return function_analyzer.collect_functions_from_table(module_result)
    end
    return {}
end

function function_analyzer.extract_functions(filepath)
    local chunk = function_analyzer.parse_file_content(filepath)
    if not chunk then
        return {}  -- Skip files with syntax errors
    end

    local stub_env = function_analyzer.create_stub_environment()
    local success, module_result = function_analyzer.execute_in_stub_env(chunk, stub_env)
    if not success then
        return {}  -- Skip files that can't execute
    end

    return function_analyzer.extract_function_info(module_result)
end

return function_analyzer
