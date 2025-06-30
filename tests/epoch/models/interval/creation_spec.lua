-- tests/epoch/models/interval/creation_spec.lua

local creation = require('epoch.models.interval.creation')

describe("models interval creation", function()
  describe("create", function()
    it("should create a new interval with required fields", function()
      local interval = creation.create("acme-corp", "website", "development")

      assert.equals("acme-corp", interval.client)
      assert.equals("website", interval.project)
      assert.equals("development", interval.task)
      assert.is_not_nil(interval.start)
      assert.equals("", interval.stop)
      assert.same({}, interval.notes)
    end)

    it("should use provided start time when given", function()
      local interval = creation.create("client", "project", "task", "9:00 AM")

      assert.equals("9:00 AM", interval.start)
    end)
  end)

  describe("close", function()
    it("should set stop time for open interval", function()
      local interval = fixtures.get('intervals.invalid.unclosed')

      local success = creation.close(interval, "10:30 AM")

      assert.is_true(success)
      assert.equals("10:30 AM", interval.stop)
    end)

    it("should not close already closed interval", function()
      local interval = fixtures.get('intervals.valid.frontend')
      local original_stop = interval.stop

      local success = creation.close(interval, "10:30 AM")

      assert.is_false(success)
      assert.equals(original_stop, interval.stop)
    end)
  end)

  describe("is_open", function()
    it("should return true for interval with empty stop time", function()
      local interval = fixtures.get('intervals.invalid.unclosed')

      local is_open = creation.is_open(interval)

      assert.is_true(is_open)
    end)

    it("should return false for interval with stop time", function()
      local interval = fixtures.get('intervals.valid.frontend')

      local is_open = creation.is_open(interval)

      assert.is_false(is_open)
    end)
  end)
end)
