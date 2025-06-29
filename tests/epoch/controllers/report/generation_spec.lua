-- tests/epoch/controllers/report/generation_spec.lua

local generation = require('epoch.controllers.report.generation')

describe("controllers report generation", function()
  describe("create", function()
    it("should create a new empty report", function()
      local report = generation.create()

      assert.same({}, report.timesheets)
      assert.same({}, report.summary)
      assert.equals(0, report.total_minutes)
      assert.same({}, report.dates)
      assert.is_nil(report.date_range)
      assert.same({}, report.weeks)
    end)
  end)

  describe("add_timesheet", function()
    it("should add timesheet to report", function()
      local report = generation.create()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      generation.add_timesheet(report, timesheet)

      assert.equals(1, #report.timesheets)
      assert.same(timesheet, report.timesheets[1])
      assert.equals(1, #report.dates)
      assert.equals(timesheet.date, report.dates[1])
    end)

    it("should update date range when adding timesheets", function()
      local report = generation.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      generation.add_timesheet(report, timesheets[1])  -- 2025-04-28
      generation.add_timesheet(report, timesheets[3])  -- 2025-05-05

      assert.equals("2025-04-28", report.date_range.first)
      assert.equals("2025-05-05", report.date_range.last)
    end)

    it("should update total minutes from timesheet intervals", function()
      local report = generation.create()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')

      generation.add_timesheet(report, timesheet)

      assert.equals(180, report.total_minutes)
    end)
  end)

  describe("calculate_total_minutes", function()
    it("should sum minutes from all completed intervals", function()
      local report = generation.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        generation.add_timesheet(report, timesheet)
      end

      local total = generation.calculate_total_minutes(report)

      assert.equals(825, total)
    end)

    it("should ignore incomplete intervals", function()
      local report = generation.create()
      local timesheet_complete = fixtures.get('timesheets.valid.past_day')
      local timesheet_with_open = fixtures.get('timesheets.valid.with_unclosed_intervals')
      generation.add_timesheet(report, timesheet_complete)
      generation.add_timesheet(report, timesheet_with_open)

      local total = generation.calculate_total_minutes(report)

      assert.equals(45, total)
    end)
  end)

  describe("get_timesheets_by_date_range", function()
    it("should return timesheets within date range", function()
      local report = generation.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        generation.add_timesheet(report, timesheet)
      end

      local filtered = generation.get_timesheets_by_date_range(report, "2025-04-28", "2025-04-30")

      assert.equals(2, #filtered)
    end)

    it("should return all timesheets when no date range specified", function()
      local report = generation.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        generation.add_timesheet(report, timesheet)
      end

      local all_timesheets = generation.get_timesheets_by_date_range(report)

      assert.equals(#timesheets, #all_timesheets)
    end)
  end)

  describe("group_by_week", function()
    it("should group timesheets by week number", function()
      local report = generation.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        generation.add_timesheet(report, timesheet)
      end
      generation.group_by_week(report)

      local expected_weeks = fixtures.get('reports.expected_structure.week_count')
      assert.equals(expected_weeks, #report.weeks)
    end)

    it("should calculate week totals", function()
      local report = generation.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        generation.add_timesheet(report, timesheet)
      end
      generation.group_by_week(report)

      assert.is_true(#report.weeks > 0)
      for _, week in ipairs(report.weeks) do
        assert.is_true(week.total_minutes >= 0)
      end
    end)
  end)

  describe("validate", function()
    it("should validate well-formed report", function()
      local report = generation.create()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      generation.add_timesheet(report, timesheet)

      local is_valid, error_msg = generation.validate(report)

      assert.is_true(is_valid)
      assert.is_nil(error_msg)
    end)

    it("should validate empty report", function()
      local empty_report = fixtures.get('reports.main_report_data.empty_report')

      local is_valid, error_msg = generation.validate(empty_report)

      assert.is_true(is_valid)
      assert.is_nil(error_msg)
    end)

    it("should reject report missing required fields", function()
      local invalid_report = {
        timesheets = {}
        -- missing other required fields
      }

      local is_valid, error_msg = generation.validate(invalid_report)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)
  end)
end)