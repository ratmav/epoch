-- tests/storage/serializer/table_serializer_spec.lua

local table_serializer = require('epoch.storage.serializer.table_serializer')
local serializer_fixtures = require('tests.storage.fixtures.serializer_fixtures')

describe("storage serializer table_serializer", function()
  describe("serialize_regular_keys", function()
    it("serializes table keys in sorted order", function()
      local spaces = ""
      local result = "{\n"
      local indent = 0

      local output = table_serializer.serialize_regular_keys(
        serializer_fixtures.tables.sorted_keys, spaces, result, indent)

      -- Check that keys appear in sorted order
      local alpha_pos = output:find('"alpha"')
      local beta_pos = output:find('"beta"')
      local zebra_pos = output:find('"zebra"')

      assert.truthy(alpha_pos)
      assert.truthy(beta_pos)
      assert.truthy(zebra_pos)

      assert.is_true(alpha_pos < beta_pos)
      assert.is_true(beta_pos < zebra_pos)
    end)

    it("handles numeric keys", function()
      local spaces = ""
      local result = "{\n"
      local indent = 0

      local output = table_serializer.serialize_regular_keys(
        serializer_fixtures.tables.numeric_keys, spaces, result, indent)

      assert.truthy(output:match('%[1%]'))
      assert.truthy(output:match('%[2%]'))
      assert.truthy(output:match('%[3%]'))
    end)

    it("handles string keys", function()
      local spaces = ""
      local result = "{\n"
      local indent = 0

      local output = table_serializer.serialize_regular_keys(
        serializer_fixtures.tables.mixed_keys, spaces, result, indent)

      assert.truthy(output:match('"string_key"'))
      assert.truthy(output:match('"another_key"'))
    end)

    it("handles numeric keys only", function()
      local spaces = ""
      local result = "{\n"
      local indent = 0

      local output = table_serializer.serialize_regular_keys(
        serializer_fixtures.tables.numeric_keys_only, spaces, result, indent)

      assert.truthy(output:match('%[42%]'))
      assert.truthy(output:match('%[1%]'))
    end)
  end)
end)