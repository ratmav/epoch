-- tests/storage/serializer/interval_serializer_spec.lua

-- Require main serializer to set up dependencies
require('epoch.storage.serializer')
local interval_serializer = require('epoch.storage.serializer.interval_serializer')

describe("storage serializer interval_serializer", function()
  describe("is_interval", function()
    it("returns true for valid intervals", function()
      local interval = fixtures.get('intervals.valid.frontend')
      assert.is_true(interval_serializer.is_interval(interval))
    end)

    it("returns false for incomplete intervals", function()
      assert.is_false(interval_serializer.is_interval({client = "test"}))
      assert.is_false(interval_serializer.is_interval({client = "test", project = "test"}))
      assert.is_false(interval_serializer.is_interval({}))
      assert.is_false(interval_serializer.is_interval(nil))
    end)
  end)

  describe("serialize_interval_keys", function()
    it("serializes interval with proper key order", function()
      local interval = fixtures.get('intervals.valid.frontend')
      local spaces = ""
      local result = "{\n"
      local indent = 0

      local output = interval_serializer.serialize_interval_keys(interval, spaces, result, indent)

      -- Check that keys appear in the expected order
      local client_pos = output:find('"client"')
      local project_pos = output:find('"project"')
      local task_pos = output:find('"task"')
      local start_pos = output:find('"start"')

      assert.truthy(client_pos)
      assert.truthy(project_pos)
      assert.truthy(task_pos)
      assert.truthy(start_pos)

      assert.is_true(client_pos < project_pos)
      assert.is_true(project_pos < task_pos)
      assert.is_true(task_pos < start_pos)
    end)

    it("skips nil values", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "9:00 AM"
        -- stop is nil
      }
      local spaces = ""
      local result = "{\n"
      local indent = 0

      local output = interval_serializer.serialize_interval_keys(interval, spaces, result, indent)

      assert.truthy(output:match('"client"'))
      assert.is_falsy(output:match('"stop"'))
    end)
  end)
end)