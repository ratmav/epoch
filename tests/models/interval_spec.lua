-- tests/models/interval_spec.lua

local interval_model = require('epoch.models.interval')

describe("models interval", function()
  describe("create", function()
    it("should create a new interval with required fields", function()
      local interval = interval_model.create("acme-corp", "website", "development")

      assert.equals("acme-corp", interval.client)
      assert.equals("website", interval.project)
      assert.equals("development", interval.task)
      assert.is_not_nil(interval.start)
      assert.equals("", interval.stop)
      assert.same({}, interval.notes)
    end)

    it("should accept custom start time", function()
      local custom_time = "09:30 AM"
      local interval = interval_model.create("client", "proj", "task", custom_time)

      assert.equals(custom_time, interval.start)
    end)
  end)

  describe("close", function()
    it("should close an open interval", function()
      local unclosed_interval = fixtures.get('intervals.invalid.unclosed')

      local success = interval_model.close(unclosed_interval, "10:30 AM")

      assert.is_true(success)
      assert.equals("10:30 AM", unclosed_interval.stop)
    end)

    it("should not close an already closed interval", function()
      local closed_interval = fixtures.get('intervals.valid.frontend')
      local original_stop = closed_interval.stop

      local success = interval_model.close(closed_interval, "11:00 AM")

      assert.is_false(success)
      assert.equals(original_stop, closed_interval.stop)
    end)

    it("should use current time if no stop time provided", function()
      local unclosed_interval = fixtures.get('intervals.invalid.unclosed')
      unclosed_interval.stop = ""  -- Reset to open state

      local success = interval_model.close(unclosed_interval)

      assert.is_true(success)
      assert.is_not_nil(unclosed_interval.stop)
      assert.is_not_equal("", unclosed_interval.stop)
    end)
  end)

  describe("is_open", function()
    it("should return true for intervals with empty stop time", function()
      local unclosed_interval = fixtures.get('intervals.invalid.unclosed')

      assert.is_true(interval_model.is_open(unclosed_interval))
    end)

    it("should return true for intervals without stop field", function()
      local no_stop_interval = fixtures.get('intervals.serializer.no_stop_time')

      assert.is_true(interval_model.is_open(no_stop_interval))
    end)

    it("should return false for intervals with stop time", function()
      local closed_interval = fixtures.get('intervals.valid.frontend')

      assert.is_false(interval_model.is_open(closed_interval))
    end)
  end)

  describe("is_complete", function()
    it("should return true for intervals with all required fields", function()
      local complete_interval = fixtures.get('intervals.valid.frontend')

      assert.is_true(interval_model.is_complete(complete_interval))
    end)

    it("should return false for intervals missing client", function()
      local missing_client = fixtures.get('intervals.invalid.missing_client')

      assert.is_false(interval_model.is_complete(missing_client))
    end)

    it("should return false for intervals missing project", function()
      local missing_project = fixtures.get('intervals.invalid.missing_project')

      assert.is_false(interval_model.is_complete(missing_project))
    end)

    it("should return false for intervals missing task", function()
      local missing_task = fixtures.get('intervals.invalid.missing_task')

      assert.is_false(interval_model.is_complete(missing_task))
    end)

    it("should return false for open intervals", function()
      local unclosed_interval = fixtures.get('intervals.invalid.unclosed')

      assert.is_false(interval_model.is_complete(unclosed_interval))
    end)
  end)

  describe("calculate_duration_minutes", function()
    it("should calculate duration for valid time intervals", function()
      local frontend_interval = fixtures.get('intervals.valid.frontend')

      local duration = interval_model.calculate_duration_minutes(frontend_interval)
      assert.equals(90, duration)
    end)

    it("should return 0 for incomplete intervals", function()
      local unclosed_interval = fixtures.get('intervals.invalid.unclosed')

      local duration = interval_model.calculate_duration_minutes(unclosed_interval)
      assert.equals(0, duration)
    end)

    it("should return 0 for invalid time formats", function()
      local invalid_time_interval = fixtures.get('intervals.invalid.invalid_time')

      local duration = interval_model.calculate_duration_minutes(invalid_time_interval)
      assert.equals(0, duration)
    end)
  end)
end)
