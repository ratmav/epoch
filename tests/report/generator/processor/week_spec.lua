-- tests/report/generator/processor/week_spec.lua

local week = require('epoch.report.generator.processor.week')

describe("report generator processor week", function()
  describe("group_timesheets_by_week", function()
    it("groups timesheets by week number", function()
      local timesheets = fixtures.get('reports.week_processor_data.simple_timesheets')

      local result = week.group_timesheets_by_week(timesheets)

      assert.is_table(result)
      -- Should have grouped timesheets by their week numbers
      local week_count = 0
      for _ in pairs(result) do
        week_count = week_count + 1
      end
      assert.is_true(week_count >= 1)
    end)

    it("creates proper week data structure", function()
      local timesheets = fixtures.get('reports.week_processor_data.single_timesheet')

      local result = week.group_timesheets_by_week(timesheets)

      local _, week_data = next(result)
      assert.is_table(week_data.dates)
      assert.is_table(week_data.timesheets)
      assert.truthy(week_data.date_range)

      assert.equals(1, #week_data.dates)
      assert.equals(1, #week_data.timesheets)
      assert.equals("2025-01-01", week_data.dates[1])
    end)

    it("handles empty timesheet list", function()
      local result = week.group_timesheets_by_week({})

      assert.same({}, result)
    end)
  end)

  describe("process_week_data", function()
    it("processes week data and returns summary", function()
      local week_data = fixtures.get('reports.week_processor_data.week_data_with_interval')
      local all_summary = {}

      local result = week.process_week_data("2025-01", week_data, all_summary)

      assert.equals("2025-01", result.week)
      assert.same({"2025-01-01"}, result.dates)
      assert.is_table(result.summary)
      assert.equals(90, result.total_minutes)
      assert.same({first = "2025-01-01", last = "2025-01-07"}, result.date_range)
      assert.is_table(result.daily_totals)
      assert.equals(90, result.daily_totals["2025-01-01"])
    end)

    it("sorts dates chronologically", function()
      local week_data = fixtures.get('reports.week_processor_data.week_data_for_sorting')
      local all_summary = {}

      local result = week.process_week_data("2025-01", week_data, all_summary)

      assert.equals("2025-01-01", result.dates[1])
      assert.equals("2025-01-02", result.dates[2])
      assert.equals("2025-01-03", result.dates[3])
    end)

    it("updates all_summary with week data", function()
      local week_data = fixtures.get('reports.week_processor_data.week_data_for_summary')
      local all_summary = {}

      week.process_week_data("2025-01", week_data, all_summary)

      assert.truthy(all_summary["acme|web|dev"])
      assert.equals(90, all_summary["acme|web|dev"].minutes)
    end)
  end)
end)