-- tests/report/generator/processor/day_spec.lua

local day = require('epoch.report.generator.processor.day')

describe("report generator processor day", function()
  describe("process_timesheet_intervals", function()
    it("processes complete intervals", function()
      local timesheet = fixtures.get('reports.day_processor_timesheets.complete_interval')
      local week_summary = {}
      local all_summary = {}

      local day_total = day.process_timesheet_intervals(timesheet, week_summary, all_summary)

      assert.equals(90, day_total)
      assert.truthy(week_summary["acme|web|dev"])
      assert.equals(90, week_summary["acme|web|dev"].minutes)
      assert.truthy(all_summary["acme|web|dev"])
      assert.equals(90, all_summary["acme|web|dev"].minutes)
    end)

    it("skips incomplete intervals", function()
      local timesheet = fixtures.get('reports.day_processor_timesheets.incomplete_interval')
      local week_summary = {}
      local all_summary = {}

      local day_total = day.process_timesheet_intervals(timesheet, week_summary, all_summary)

      assert.equals(0, day_total)
      assert.is_nil(week_summary["acme|web|"])
      assert.is_nil(all_summary["acme|web|"])
    end)

    it("accumulates multiple intervals", function()
      local timesheet = fixtures.get('reports.day_processor_timesheets.multiple_intervals')
      local week_summary = {}
      local all_summary = {}

      local day_total = day.process_timesheet_intervals(timesheet, week_summary, all_summary)

      assert.equals(150, day_total) -- 90 + 60
      assert.equals(150, week_summary["acme|web|dev"].minutes)
      assert.equals(150, all_summary["acme|web|dev"].minutes)
    end)

    it("handles intervals without stop time", function()
      local timesheet = fixtures.get('reports.day_processor_timesheets.no_stop_time')
      local week_summary = {}
      local all_summary = {}

      local day_total = day.process_timesheet_intervals(timesheet, week_summary, all_summary)

      assert.equals(0, day_total)
      assert.equals(0, week_summary["acme|web|dev"].minutes)
    end)
  end)
end)