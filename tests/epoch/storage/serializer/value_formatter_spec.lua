-- tests/storage/serializer/value_formatter_spec.lua

local value_formatter = require('epoch.storage.serializer.value_formatter')
local fixtures = require('fixtures.init')

describe("storage serializer value_formatter", function()
  describe("format_value", function()
    it("formats strings with quotes", function()
      assert.equals('"hello"', value_formatter.format_value(fixtures.get('storage.values.string'), 0))
      assert.equals('"test string"', value_formatter.format_value(fixtures.get('storage.values.long_string'), 0))
    end)

    it("formats numbers as strings", function()
      assert.equals("123", value_formatter.format_value(fixtures.get('storage.values.number'), 0))
      assert.equals("45.67", value_formatter.format_value(fixtures.get('storage.values.float'), 0))
    end)

    it("formats booleans as strings", function()
      assert.equals("true", value_formatter.format_value(fixtures.get('storage.values.boolean_true'), 0))
      assert.equals("false", value_formatter.format_value(fixtures.get('storage.values.boolean_false'), 0))
    end)

    it("formats nil as string", function()
      assert.equals("nil", value_formatter.format_value(nil, 0))
    end)
  end)
end)