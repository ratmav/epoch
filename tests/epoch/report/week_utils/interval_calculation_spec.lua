-- tests/report/week_utils/interval_calculation_spec.lua

local interval_calculation = require('epoch.report.week_utils.interval_calculation')

describe("report week_utils interval_calculation", function()
  describe("calculate_interval_minutes", function()
    it("calculates minutes for complete intervals", function()
      local interval = fixtures.get('reports.week_utils_data.complete_interval')
      local date = fixtures.get('reports.week_utils_data.test_date')

      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(90, minutes)
    end)

    it("returns 0 for incomplete intervals", function()
      local interval = fixtures.get('reports.week_utils_data.incomplete_interval')
      local date = fixtures.get('reports.week_utils_data.test_date')

      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(0, minutes)
    end)

    it("returns 0 for intervals with empty stop time", function()
      local interval = fixtures.get('reports.week_utils_data.empty_stop_interval')
      local date = fixtures.get('reports.week_utils_data.test_date')

      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(0, minutes)
    end)

    it("returns 0 for intervals with invalid time formats", function()
      local interval = fixtures.get('reports.week_utils_data.invalid_time_interval')
      local date = fixtures.get('reports.week_utils_data.test_date')

      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(0, minutes)
    end)

    it("handles negative durations by returning 0", function()
      local interval = fixtures.get('reports.week_utils_data.negative_duration_interval')
      local date = fixtures.get('reports.week_utils_data.test_date')

      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(0, minutes)
    end)
  end)
end)