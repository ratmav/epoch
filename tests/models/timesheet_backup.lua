-- tests/models/timesheet_spec.lua

local timesheet_model = require('epoch.models.timesheet')

describe("models timesheet", function()
  describe("create", function()
    it("should create a new timesheet for a date", function()
      local timesheet = timesheet_model.create("2025-01-15")

      assert.equals("2025-01-15", timesheet.date)
      assert.same({}, timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)

    it("should use today's date when no date provided", function()
      local timesheet = timesheet_model.create()
      local today = os.date("%Y-%m-%d")

      assert.equals(today, timesheet.date)
      assert.same({}, timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)
  end)

  describe("add_interval", function()
    it("should add interval to timesheet", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local interval = fixtures.get('intervals.valid.frontend')

      timesheet_model.add_interval(timesheet, interval)

      assert.equals(1, #timesheet.intervals)
      assert.same(interval, timesheet.intervals[1])
    end)

    it("should update daily total when adding completed interval", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local interval = fixtures.get('intervals.valid.frontend')

      timesheet_model.add_interval(timesheet, interval)

      assert.equals("01:30", timesheet.daily_total)
    end)

    it("should not update daily total for incomplete intervals", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local interval = fixtures.get('intervals.invalid.unclosed')

      timesheet_model.add_interval(timesheet, interval)

      assert.equals("00:00", timesheet.daily_total)
    end)
  end)

  describe("close_current_interval", function()
    it("should close the most recent open interval", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local open_interval = fixtures.get('intervals.invalid.unclosed')
      timesheet_model.add_interval(timesheet, open_interval)

      local success = timesheet_model.close_current_interval(timesheet, "11:00 AM")

      assert.is_true(success)
      assert.equals("11:00 AM", timesheet.intervals[1].stop)
    end)

    it("should return false when no open intervals exist", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local closed_interval = fixtures.get('intervals.valid.frontend')
      timesheet_model.add_interval(timesheet, closed_interval)

      local success = timesheet_model.close_current_interval(timesheet, "11:00 AM")

      assert.is_false(success)
    end)

    it("should return false when timesheet has no intervals", function()
      local timesheet = timesheet_model.create("2025-01-15")

      local success = timesheet_model.close_current_interval(timesheet, "11:00 AM")

      assert.is_false(success)
    end)

    it("should update daily total after closing interval", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local open_interval = fixtures.get('intervals.invalid.unclosed')
      timesheet_model.add_interval(timesheet, open_interval)

      timesheet_model.close_current_interval(timesheet, "10:30 AM")

      assert.equals("01:30", timesheet.daily_total)
    end)
  end)

  describe("has_open_interval", function()
    it("should return true when timesheet has open interval", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local open_interval = fixtures.get('intervals.invalid.unclosed')
      timesheet_model.add_interval(timesheet, open_interval)

      assert.is_true(timesheet_model.has_open_interval(timesheet))
    end)

    it("should return false when all intervals are closed", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local closed_interval = fixtures.get('intervals.valid.frontend')
      timesheet_model.add_interval(timesheet, closed_interval)

      assert.is_false(timesheet_model.has_open_interval(timesheet))
    end)

    it("should return false when timesheet has no intervals", function()
      local timesheet = timesheet_model.create("2025-01-15")

      assert.is_false(timesheet_model.has_open_interval(timesheet))
    end)
  end)

  describe("calculate_daily_total", function()
    it("should calculate total from multiple completed intervals", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local interval1 = fixtures.get('intervals.valid.frontend')  -- 90 minutes
      local interval2 = fixtures.get('intervals.valid.personal')  -- 45 minutes

      timesheet_model.add_interval(timesheet, interval1)
      timesheet_model.add_interval(timesheet, interval2)

      assert.equals("02:15", timesheet.daily_total)
    end)

    it("should ignore incomplete intervals in calculation", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local complete_interval = fixtures.get('intervals.valid.frontend')
      local incomplete_interval = fixtures.get('intervals.invalid.unclosed')

      timesheet_model.add_interval(timesheet, complete_interval)
      timesheet_model.add_interval(timesheet, incomplete_interval)

      assert.equals("01:30", timesheet.daily_total)
    end)

    it("should return 00:00 for timesheet with no intervals", function()
      local timesheet = timesheet_model.create("2025-01-15")

      assert.equals("00:00", timesheet.daily_total)
    end)
  end)

  describe("get_completed_intervals", function()
    it("should return only completed intervals", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local complete_interval = fixtures.get('intervals.valid.frontend')
      local incomplete_interval = fixtures.get('intervals.invalid.unclosed')

      timesheet_model.add_interval(timesheet, complete_interval)
      timesheet_model.add_interval(timesheet, incomplete_interval)

      local completed = timesheet_model.get_completed_intervals(timesheet)

      assert.equals(1, #completed)
      assert.same(complete_interval, completed[1])
    end)

    it("should return empty array when no completed intervals", function()
      local timesheet = timesheet_model.create("2025-01-15")
      local incomplete_interval = fixtures.get('intervals.invalid.unclosed')
      timesheet_model.add_interval(timesheet, incomplete_interval)

      local completed = timesheet_model.get_completed_intervals(timesheet)

      assert.same({}, completed)
    end)
  end)

  describe("validate", function()
    it("should validate well-formed timesheet", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      local is_valid, error_msg = timesheet_model.validate(timesheet)

      assert.is_true(is_valid)
      assert.is_nil(error_msg)
    end)

    it("should reject timesheet missing date", function()
      local invalid_timesheet = {
        intervals = {},
        daily_total = "00:00"
      }

      local is_valid, error_msg = timesheet_model.validate(invalid_timesheet)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject timesheet missing intervals", function()
      local invalid_timesheet = {
        date = "2025-01-15",
        daily_total = "00:00"
      }

      local is_valid, error_msg = timesheet_model.validate(invalid_timesheet)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)

    it("should reject timesheet with invalid intervals", function()
      local invalid_timesheet = {
        date = "2025-01-15",
        intervals = {
          fixtures.get('intervals.invalid.missing_client')
        },
        daily_total = "00:00"
      }

      local is_valid, error_msg = timesheet_model.validate(invalid_timesheet)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)
  end)
end)
