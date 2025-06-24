-- tests/laconic/discovery_spec.lua

local discovery = require('laconic.discovery')

describe('laconic discovery', function()
  describe('find_lua_files', function()
    it('should find lua files in directory', function()
      local files = discovery.find_lua_files('tests/fixtures/laconic')

      assert.is_true(#files >= 3)

      -- Check that we found our fixture files
      local found_files = {}
      for _, file in ipairs(files) do
        local basename = file:match("([^/]+)$")
        found_files[basename] = true
      end

      assert.is_true(found_files['compliant.lua'])
      assert.is_true(found_files['long_function.lua'])
      assert.is_true(found_files['long_file.lua'])
    end)

    it('should return empty table for non-existent directory', function()
      local files = discovery.find_lua_files('tests/fixtures/does_not_exist')
      assert.equals(0, #files)
    end)
  end)
end)
