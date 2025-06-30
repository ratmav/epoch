-- tests/report/week_utils/range_calculation_spec.lua

local range_calculation = require('epoch.report.week_utils.range_calculation')

describe("report week_utils range_calculation", function()
  describe("get_week_date_range", function()
    it("returns date range for valid week string", function()
      local range = range_calculation.get_week_date_range("2025-01")

      assert.is_table(range)
      assert.truthy(range.first)
      assert.truthy(range.last)
      assert.matches("%d%d%d%d%-%d%d%-%d%d", range.first)
      assert.matches("%d%d%d%d%-%d%d%-%d%d", range.last)
    end)

    it("returns nil for invalid week string", function()
      assert.is_nil(range_calculation.get_week_date_range("invalid"))
      assert.is_nil(range_calculation.get_week_date_range("2025"))
      assert.is_nil(range_calculation.get_week_date_range(""))
      assert.is_nil(range_calculation.get_week_date_range(nil))
    end)

    it("calculates week range spanning 7 days", function()
      local range = range_calculation.get_week_date_range("2025-01")

      if range then
        local first_parts = {range.first:match("(%d+)-(%d+)-(%d+)")}
        local last_parts = {range.last:match("(%d+)-(%d+)-(%d+)")}

        local first_date = os.time({
          year = tonumber(first_parts[1]),
          month = tonumber(first_parts[2]),
          day = tonumber(first_parts[3])
        })
        local last_date = os.time({
          year = tonumber(last_parts[1]),
          month = tonumber(last_parts[2]),
          day = tonumber(last_parts[3])
        })

        local diff_days = (last_date - first_date) / 86400
        assert.equals(6, diff_days)
      end
    end)
  end)
end)