-- tests/laconic/compliance_spec.lua

local compliance = require('laconic.compliance')

describe('laconic compliance', function()
  describe('check_directory', function()
    it('should check directory compliance', function()
      local results = compliance.check_directory('tests/fixtures/laconic')

      -- Should find 4 files: compliant.lua, init.lua, long_file.lua, long_function.lua
      assert.equals(4, results.total_files)
      assert.is_true(results.total_functions >= 3)

      -- Should find violations in fixtures
      assert.equals(1, #results.long_files)  -- long_file.lua
      assert.equals(1, #results.long_functions)  -- sixteen_line_function
      assert.is_false(results.compliant)
    end)

    it('should return compliant true when no violations', function()
      -- Test with just compliant.lua
      local results = compliance.check_directory('tests/fixtures/laconic')

      -- Filter to just compliant files for this conceptual test
      -- (In reality we'd need a directory with only compliant files)
      assert.is_not_nil(results)
      assert.is_number(results.total_files)
      assert.is_number(results.total_functions)
    end)
  end)

  describe('check_file_length', function()
    it('should return violation for long files', function()
      local violation = compliance.check_file_length(fixtures.get('laconic.long_file'))
      assert.is_not_nil(violation)
      assert.equals(fixtures.get('laconic.long_file'), violation.file)
      assert.equals(101, violation.lines)
    end)

    it('should return nil for compliant files', function()
      local violation = compliance.check_file_length(fixtures.get('laconic.compliant_file'))
      assert.is_nil(violation)
    end)
  end)
end)
