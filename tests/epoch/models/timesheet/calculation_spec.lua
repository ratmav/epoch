-- tests/models/timesheet/calculation_spec.lua

local calculation = require('epoch.models.timesheet.calculation')

describe("models timesheet calculation", function()
  describe("calculate_daily_total", function()
    it("should calculate total from completed intervals", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      local total = calculation.calculate_daily_total(timesheet)

      assert.equals("03:00", total)
    end)

    it("should return zero for empty timesheet", function()
      local timesheet = fixtures.get('timesheets.valid.empty')

      local total = calculation.calculate_daily_total(timesheet)

      assert.equals("00:00", total)
    end)

    it("should ignore incomplete intervals", function()
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')

      local total = calculation.calculate_daily_total(timesheet)

      assert.equals("00:00", total)
    end)
  end)

  describe("update_daily_total", function()
    it("should update timesheet daily_total field", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      timesheet.daily_total = "00:00"  -- Reset

      calculation.update_daily_total(timesheet)

      assert.equals("03:00", timesheet.daily_total)
    end)
  end)
end)
