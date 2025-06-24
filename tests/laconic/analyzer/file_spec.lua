-- tests/laconic/analyzer/file_spec.lua

local file_analyzer = require('laconic.analyzer.file')

describe('laconic analyzer file', function()
  describe('count_lines', function()
    it('should detect compliant file length (100 lines or fewer)', function()
      local line_count = file_analyzer.count_lines(fixtures.get('laconic.compliant_file'))
      assert.is_true(line_count <= 100)
    end)

    it('should detect file length violations (over 100 lines)', function()
      local line_count = file_analyzer.count_lines(fixtures.get('laconic.long_file'))
      assert.equals(101, line_count)
      assert.is_true(line_count > 100)
    end)

    it('should return 0 for non-existent files', function()
      local line_count = file_analyzer.count_lines('tests/fixtures/laconic/does_not_exist.lua')
      assert.equals(0, line_count)
    end)
  end)
end)
