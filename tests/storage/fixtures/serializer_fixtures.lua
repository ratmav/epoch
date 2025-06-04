-- tests/storage/fixtures/serializer_fixtures.lua
-- Serializer test data fixtures

local serializer_fixtures = {}

-- Array test data
serializer_fixtures.arrays = {
  empty = {},
  strings = {"first", "second", "third"},
  mixed_types = {"string", 123, true},
  single_item = {"a"}
}

-- Non-array test data
serializer_fixtures.non_arrays = {
  object = {a = 1},
  sparse = {[1] = "a", [3] = "c"},
  mixed_keys = {a = 1, b = 2},
  string = "not a table",
  number = 123
}

-- Value formatting test data
serializer_fixtures.values = {
  string = "hello",
  long_string = "test string",
  number = 123,
  float = 45.67,
  boolean_true = true,
  boolean_false = false,
  nil_value = nil
}

-- Table test data for serialization
serializer_fixtures.tables = {
  sorted_keys = {
    zebra = "last",
    alpha = "first",
    beta = "second"
  },
  numeric_keys = {
    [3] = "third",
    [1] = "first",
    [2] = "second"
  },
  mixed_keys = {
    string_key = "value1",
    another_key = "value2"
  },

  numeric_keys_only = {
    [42] = "value2",
    [1] = "value1"
  }
}

-- Array serialization test data
serializer_fixtures.array_serialization = {
  simple = {"first", "second", "third"},
  empty = {},
  mixed = {"string", 123, true}
}

return serializer_fixtures