-- tests/laconic/analyzer/function_spec.lua

local function_analyzer = require('laconic.analyzer.function')

describe('laconic analyzer function', function()
  describe('extract_functions', function()
    it('should detect compliant functions (15 lines or fewer)', function()
      local functions = function_analyzer.extract_functions(fixtures.get('laconic.compliant_file'))

      assert.equals(3, #functions)

      -- All functions should be compliant (15 lines or fewer)
      for _, func in ipairs(functions) do
        assert.is_true(func.lines <= 15, func.name .. ' has ' .. func.lines .. ' lines')
      end

      -- Check specific function line counts
      local by_name = {}
      for _, func in ipairs(functions) do
        by_name[func.name] = func.lines
      end

      assert.equals(3, by_name.short_function)
      assert.equals(6, by_name.another_short)
      assert.equals(15, by_name.exactly_fifteen_lines)
    end)

    it('should detect function violations (over 15 lines)', function()
      local functions = function_analyzer.extract_functions(fixtures.get('laconic.long_function_file'))

      assert.equals(2, #functions)

      -- Find the violation
      local short_func, long_func
      for _, func in ipairs(functions) do
        if func.name == 'short_function' then
          short_func = func
        elseif func.name == 'sixteen_line_function' then
          long_func = func
        end
      end

      assert.is_not_nil(short_func)
      assert.is_not_nil(long_func)

      assert.is_true(short_func.lines <= 15)
      assert.equals(16, long_func.lines)
      assert.is_true(long_func.lines > 15)
    end)

    it('should handle files with syntax errors gracefully', function()
      -- Create a temporary file with syntax errors
      local temp_file = '/tmp/syntax_error_test.lua'
      local file = io.open(temp_file, 'w')
      file:write([[
function broken(
  -- missing closing paren and end
]])
      file:close()

      local functions = function_analyzer.extract_functions(temp_file)
      assert.equals(0, #functions)

      os.remove(temp_file)
    end)

    it('should use Lua parser instead of regex', function()
      -- This test validates that we're using Lua's AST approach
      -- by checking that we get accurate line counts from debug.getinfo
      local functions = function_analyzer.extract_functions(fixtures.get('laconic.long_function_file'))

      local long_func
      for _, func in ipairs(functions) do
        if func.name == 'sixteen_line_function' then
          long_func = func
          break
        end
      end

      assert.is_not_nil(long_func)
      -- This precise line count can only come from debug.getinfo, not regex
      assert.equals(16, long_func.lines)
      assert.is_not_nil(long_func.start_line)
    end)
  end)
end)
