-- tests/storage/serializer/array_serializer_spec.lua

local array_serializer = require('epoch.storage.serializer.array_serializer')
local serializer_fixtures = require('tests.storage.fixtures.serializer_fixtures')

describe("storage serializer array_serializer", function()
  describe("serialize_array_elements", function()
    it("serializes array elements with proper indentation", function()
      local spaces = ""
      local result = "{\n"
      local indent = 0

      local test_data = serializer_fixtures.array_serialization.simple
      local output = array_serializer.serialize_array_elements(test_data, spaces, result, indent)

      assert.truthy(output:match('"first"'))
      assert.truthy(output:match('"second"'))
      assert.truthy(output:match('"third"'))
      assert.truthy(output:match('  "first",\n'))
    end)

    it("handles empty arrays", function()
      local spaces = ""
      local result = "{\n"
      local indent = 0

      local test_data = serializer_fixtures.array_serialization.empty
      local output = array_serializer.serialize_array_elements(test_data, spaces, result, indent)

      assert.equals("{\n", output)
    end)

    it("handles arrays with different value types", function()
      local spaces = ""
      local result = "{\n"
      local indent = 0

      local test_data = serializer_fixtures.array_serialization.mixed
      local output = array_serializer.serialize_array_elements(test_data, spaces, result, indent)

      assert.truthy(output:match('"string"'))
      assert.truthy(output:match('123'))
      assert.truthy(output:match('true'))
    end)
  end)
end)