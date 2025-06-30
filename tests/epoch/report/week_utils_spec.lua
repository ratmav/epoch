-- tests/report/week_utils_spec.lua

local week_utils = require('epoch.report.week_utils')

describe("report week_utils", function()
  describe("get_week_number", function()
    it("delegates to date calculation module", function()
      local week = week_utils.get_week_number("2025-01-01")

      assert.is_string(week)
      assert.matches("%d%d%d%d%-%d%d", week)
    end)
  end)

  describe("get_week_date_range", function()
    it("delegates to range calculation module", function()
      local range = week_utils.get_week_date_range("2025-01")

      assert.is_table(range)
      assert.truthy(range.first)
      assert.truthy(range.last)
    end)
  end)

  describe("calculate_interval_minutes", function()
    it("delegates to interval calculation module", function()
      local interval = fixtures.get('reports.test_intervals.simple')
      local date = "2025-01-01"

      local minutes = week_utils.calculate_interval_minutes(interval, date)

      assert.equals(90, minutes)
    end)
  end)
end)