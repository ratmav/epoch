-- ui_interval_calculation_spec.lua
-- Test the ui/interval/calculation module

describe("ui interval calculation", function()
  local calculation = require('epoch.interval.calculation')

  describe("calculate_daily_total", function()
    it("should calculate correct total for valid intervals", function()
      local timesheet = fixtures.get("timesheets.valid.with_intervals")

      local total = calculation.calculate_daily_total(timesheet)

      assert.is_string(total)
      assert.is_not.equals("00:00", total)  -- Should have some time
    end)

    it("should return 00:00 for empty timesheet", function()
      local timesheet = fixtures.get("timesheets.valid.empty")

      local total = calculation.calculate_daily_total(timesheet)

      assert.equals("00:00", total)
    end)

    it("should ignore unclosed intervals", function()
      local timesheet = fixtures.get("timesheets.valid.with_unclosed_intervals")

      local total = calculation.calculate_daily_total(timesheet)

      assert.equals("00:00", total)
    end)

    it("should handle invalid timesheet structure", function()
      local invalid_timesheet = fixtures.get("timesheets.storage.incomplete_interval")

      local total = calculation.calculate_daily_total(invalid_timesheet)

      assert.equals("00:00", total)
    end)
  end)

  describe("calculate_interval_hours", function()
    it("should calculate hours for complete interval", function()
      local interval = fixtures.get("intervals.valid.frontend")

      local hours = calculation.calculate_interval_hours(interval)

      assert.is_number(hours)
      assert.is_true(hours > 0)
    end)

    it("should return nil for incomplete interval", function()
      local interval = fixtures.get("intervals.invalid.unclosed")

      local hours = calculation.calculate_interval_hours(interval)

      assert.is_nil(hours)
    end)

    it("should calculate correct decimal hours", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "09:00 AM",
        stop = "10:30 AM",
        notes = {}
      }

      local hours = calculation.calculate_interval_hours(interval)

      assert.equals(1.5, hours)
    end)

    it("should return nil for invalid time formats", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "invalid",
        stop = "10:30 AM",
        notes = {}
      }

      local hours = calculation.calculate_interval_hours(interval)

      assert.is_nil(hours)
    end)
  end)
end)
