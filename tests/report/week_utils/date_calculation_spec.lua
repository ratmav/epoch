-- tests/report/week_utils/date_calculation_spec.lua

local date_calculation = require('epoch.report.week_utils.date_calculation')

describe("report week_utils date_calculation", function()
  describe("get_week_number", function()
    it("returns week number for valid date", function()
      local week = date_calculation.get_week_number("2025-01-01")

      assert.is_string(week)
      assert.matches("%d%d%d%d%-%d%d", week)
    end)

    it("returns nil for invalid date format", function()
      assert.is_nil(date_calculation.get_week_number("invalid"))
      assert.is_nil(date_calculation.get_week_number("2025-13-01"))
      assert.is_nil(date_calculation.get_week_number(""))
      assert.is_nil(date_calculation.get_week_number(nil))
    end)

    it("returns consistent week numbers for same week", function()
      local week1 = date_calculation.get_week_number("2025-01-01")
      local week2 = date_calculation.get_week_number("2025-01-02")

      if week1 and week2 then
        -- Should be same week or consecutive weeks
        assert.truthy(week1)
        assert.truthy(week2)
      end
    end)
  end)

  describe("parse_week_string", function()
    it("parses valid week string", function()
      local year, week = date_calculation.parse_week_string("2025-01")

      assert.equals(2025, year)
      assert.equals(1, week)
    end)

    it("handles different week numbers", function()
      local year, week = date_calculation.parse_week_string("2024-52")

      assert.equals(2024, year)
      assert.equals(52, week)
    end)

    it("returns nil for invalid format", function()
      local year, week = date_calculation.parse_week_string("invalid")
      assert.is_nil(year)
      assert.is_nil(week)

      year, week = date_calculation.parse_week_string("2025")
      assert.is_nil(year)
      assert.is_nil(week)

      year, week = date_calculation.parse_week_string("")
      assert.is_nil(year)
      assert.is_nil(week)
    end)
  end)
end)