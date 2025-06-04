-- tests/storage/serializer/value_formatter_spec.lua

local value_formatter = require('epoch.storage.serializer.value_formatter')
local serializer_fixtures = require('tests.storage.fixtures.serializer_fixtures')

describe("storage serializer value_formatter", function()
  describe("format_value", function()
    it("formats strings with quotes", function()
      assert.equals('"hello"', value_formatter.format_value(serializer_fixtures.values.string, 0))
      assert.equals('"test string"', value_formatter.format_value(serializer_fixtures.values.long_string, 0))
    end)

    it("formats numbers as strings", function()
      assert.equals("123", value_formatter.format_value(serializer_fixtures.values.number, 0))
      assert.equals("45.67", value_formatter.format_value(serializer_fixtures.values.float, 0))
    end)

    it("formats booleans as strings", function()
      assert.equals("true", value_formatter.format_value(serializer_fixtures.values.boolean_true, 0))
      assert.equals("false", value_formatter.format_value(serializer_fixtures.values.boolean_false, 0))
    end)

    it("formats nil as string", function()
      assert.equals("nil", value_formatter.format_value(serializer_fixtures.values.nil_value, 0))
    end)
  end)
end)