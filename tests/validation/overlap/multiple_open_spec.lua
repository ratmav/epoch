-- tests/validation/overlap/multiple_open_spec.lua

local multiple_open = require('epoch.validation.overlap.multiple_open')
local factory = require('epoch.factory')

describe("validation overlap multiple_open", function()
  describe("check", function()
    it("accepts no intervals", function()
      local has_multiple, _ = multiple_open.check({})
      assert.is_false(has_multiple)
    end)

    it("accepts single open interval", function()
      local single_open = factory.build_interval({
        client = "test",
        project = "test",
        task = "test",
        start = "09:00 AM"
      })
      local has_multiple, _ = multiple_open.check({single_open})
      assert.is_false(has_multiple)
    end)

    it("accepts single closed interval", function()
      local single_closed = factory.build_interval({
        client = "test",
        project = "test",
        task = "test",
        start = "09:00 AM",
        stop = "10:00 AM"
      })
      local has_multiple, _ = multiple_open.check({single_closed})
      assert.is_false(has_multiple)
    end)

    it("accepts multiple closed intervals", function()
      local closed1 = factory.build_interval({
        client = "test",
        project = "test",
        task = "task1",
        start = "09:00 AM",
        stop = "10:00 AM"
      })
      local closed2 = factory.build_interval({
        client = "test",
        project = "test",
        task = "task2",
        start = "10:30 AM",
        stop = "11:30 AM"
      })
      local has_multiple, _ = multiple_open.check({closed1, closed2})
      assert.is_false(has_multiple)
    end)

    it("rejects multiple open intervals", function()
      local open1 = factory.build_interval({
        client = "client1",
        project = "project1",
        task = "task1",
        start = "09:00 AM"
      })
      local open2 = factory.build_interval({
        client = "client2",
        project = "project2",
        task = "task2",
        start = "10:00 AM"
      })
      local has_multiple, msg = multiple_open.check({open1, open2})

      assert.is_true(has_multiple)
      assert.truthy(msg:match("multiple open intervals"))
      assert.truthy(msg:match("client1/project1/task1"))
      assert.truthy(msg:match("client2/project2/task2"))
    end)

    it("rejects multiple open intervals mixed with closed", function()
      local closed = factory.build_interval({
        client = "test",
        project = "test",
        task = "closed",
        start = "08:00 AM",
        stop = "09:00 AM"
      })
      local open1 = factory.build_interval({
        client = "test",
        project = "test",
        task = "open1",
        start = "09:30 AM"
      })
      local open2 = factory.build_interval({
        client = "test",
        project = "test",
        task = "open2",
        start = "10:30 AM"
      })
      local has_multiple, msg = multiple_open.check({closed, open1, open2})

      assert.is_true(has_multiple)
      assert.truthy(msg:match("multiple open intervals"))
      assert.truthy(msg:match("test/test/open1"))
      assert.truthy(msg:match("test/test/open2"))
    end)
  end)
end)
