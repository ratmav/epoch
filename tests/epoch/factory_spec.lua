-- factory_spec.lua
-- tests for the factory module

describe("factory", function()
  local factory = require('epoch.factory')

  describe("build_report", function()
    it("creates empty report with default values", function()
      local report = factory.build_report()

      assert.equals("table", type(report.timesheets))
      assert.equals("table", type(report.summary))
      assert.equals("number", type(report.total_minutes))
      assert.equals("table", type(report.dates))
      assert.equals("table", type(report.weeks))

      assert.equals(0, #report.timesheets)
      assert.equals(0, #report.summary)
      assert.equals(0, report.total_minutes)
      assert.equals(0, #report.dates)
      assert.equals(0, #report.weeks)
    end)

    it("creates report with custom values", function()
      local custom_summary = {{ client = "test", project = "test", task = "test", minutes = 60 }}
      local report = factory.build_report({
        summary = custom_summary,
        total_minutes = 120,
        dates = {"2025-05-12"},
        weeks = {"2025-19"}
      })

      assert.same(custom_summary, report.summary)
      assert.equals(120, report.total_minutes)
      assert.same({"2025-05-12"}, report.dates)
      assert.same({"2025-19"}, report.weeks)
    end)
  end)

  describe("build_timesheet", function()
    it("creates timesheet with default values", function()
      local timesheet = factory.build_timesheet()

      assert.equals("string", type(timesheet.date))
      assert.equals("table", type(timesheet.intervals))
      assert.equals("string", type(timesheet.daily_total))

      assert.matches("%d%d%d%d%-%d%d%-%d%d", timesheet.date)
      assert.equals(0, #timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)

    it("creates timesheet with custom values", function()
      local custom_intervals = {factory.build_interval({client = "test"})}
      local timesheet = factory.build_timesheet({
        date = "2025-05-12",
        intervals = custom_intervals,
        daily_total = "01:30"
      })

      assert.equals("2025-05-12", timesheet.date)
      assert.same(custom_intervals, timesheet.intervals)
      assert.equals("01:30", timesheet.daily_total)
    end)
  end)

  describe("build_interval", function()
    it("creates interval with default values", function()
      local interval = factory.build_interval()

      assert.equals("string", type(interval.client))
      assert.equals("string", type(interval.project))
      assert.equals("string", type(interval.task))
      assert.equals("string", type(interval.start))
      assert.equals("string", type(interval.stop))
      assert.equals("table", type(interval.notes))

      assert.equals("", interval.client)
      assert.equals("", interval.project)
      assert.equals("", interval.task)
      assert.matches("%d%d:%d%d [AP]M", interval.start)
      assert.equals("", interval.stop)
      assert.equals(0, #interval.notes)
    end)

    it("creates interval with custom values", function()
      local interval = factory.build_interval({
        client = "acme-corp",
        project = "website-redesign",
        task = "frontend-planning",
        start = "09:00 AM",
        stop = "10:30 AM",
        notes = {"test note"}
      })

      assert.equals("acme-corp", interval.client)
      assert.equals("website-redesign", interval.project)
      assert.equals("frontend-planning", interval.task)
      assert.equals("09:00 AM", interval.start)
      assert.equals("10:30 AM", interval.stop)
      assert.same({"test note"}, interval.notes)
    end)
  end)
end)