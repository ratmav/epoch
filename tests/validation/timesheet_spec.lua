-- tests/validation/timesheet_spec.lua

local timesheet_validation = require('epoch.validation.timesheet')
local factory = require('epoch.factory')

describe("validation timesheet", function()
  describe("validate", function()
    it("accepts valid timesheet with no intervals", function()
      local timesheet = factory.build_timesheet()
      local valid, err = timesheet_validation.validate(timesheet)

      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts valid timesheet with valid intervals", function()
      local interval = factory.build_interval({
        client = "test",
        project = "test",
        task = "test",
        start = "09:00 AM",
        stop = "10:00 AM"
      })
      local timesheet = factory.build_timesheet({
        intervals = {interval}
      })
      local valid, err = timesheet_validation.validate(timesheet)

      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("rejects timesheet with invalid structure", function()
      local invalid_timesheet = {
        -- missing required fields
      }
      local valid, err = timesheet_validation.validate(invalid_timesheet)

      assert.is_false(valid)
      assert.is_string(err)
    end)

    it("rejects timesheet with multiple open intervals", function()
      local open1 = factory.build_interval({
        client = "test",
        project = "test",
        task = "task1",
        start = "09:00 AM"
      })
      local open2 = factory.build_interval({
        client = "test",
        project = "test",
        task = "task2",
        start = "10:00 AM"
      })
      local timesheet = factory.build_timesheet({
        intervals = {open1, open2}
      })
      local valid, err = timesheet_validation.validate(timesheet)

      assert.is_false(valid)
      assert.truthy(err:match("multiple open intervals"))
    end)

    it("rejects timesheet with overlapping intervals", function()
      local first = factory.build_interval({
        client = "test",
        project = "test",
        task = "task1",
        start = "09:00 AM",
        stop = "10:30 AM"
      })
      local second = factory.build_interval({
        client = "test",
        project = "test",
        task = "task2",
        start = "10:00 AM",
        stop = "11:00 AM"
      })
      local timesheet = factory.build_timesheet({
        intervals = {first, second}
      })
      local valid, err = timesheet_validation.validate(timesheet)

      assert.is_false(valid)
      assert.truthy(err:match("intervals overlap"))
    end)
  end)
end)
