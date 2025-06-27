-- tests/models/timesheet/creation_spec.lua

local creation = require('epoch.models.timesheet.creation')

describe("models timesheet creation", function()
  describe("create", function()
    it("should create a new timesheet for a date", function()
      local timesheet = creation.create("2025-01-15")

      assert.equals("2025-01-15", timesheet.date)
      assert.same({}, timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)

    it("should use today's date when no date provided", function()
      local timesheet = creation.create()
      local today = os.date("%Y-%m-%d")

      assert.equals(today, timesheet.date)
      assert.same({}, timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)
  end)

  describe("add_interval", function()
    it("should add interval to empty timesheet", function()
      local timesheet = creation.create("2025-01-15")
      local interval = fixtures.get('intervals.valid.frontend')

      creation.add_interval(timesheet, interval)

      assert.equals(1, #timesheet.intervals)
      assert.same(interval, timesheet.intervals[1])
    end)

    it("should close current interval before adding new one", function()
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')
      local new_interval = fixtures.get('intervals.valid.backend')

      creation.add_interval(timesheet, new_interval)

      -- First interval should now be closed
      assert.is_not_equal("", timesheet.intervals[1].stop)
      -- New interval should be added
      assert.equals(2, #timesheet.intervals)
      assert.same(new_interval, timesheet.intervals[2])
    end)
  end)

  describe("close_current_interval", function()
    it("should close the most recent open interval", function()
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')

      local success = creation.close_current_interval(timesheet, "10:30 AM")

      assert.is_true(success)
      assert.equals("10:30 AM", timesheet.intervals[1].stop)
    end)

    it("should return false when no intervals exist", function()
      local timesheet = creation.create("2025-01-15")

      local success = creation.close_current_interval(timesheet, "10:30 AM")

      assert.is_false(success)
    end)

    it("should return false when last interval is already closed", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      local success = creation.close_current_interval(timesheet, "10:30 AM")

      assert.is_false(success)
    end)
  end)
end)
