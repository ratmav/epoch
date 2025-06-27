-- tests/controllers/report_spec.lua

local report_controller = require('epoch.controllers.report')

describe("controllers report", function()
  describe("create", function()
    it("should create a new empty report", function()
      local report_obj = report_controller.create()

      assert.same({}, report_obj.timesheets)
      assert.same({}, report_obj.summary)
      assert.equals(0, report_obj.total_minutes)
      assert.same({}, report_obj.dates)
      assert.is_nil(report_obj.date_range)
      assert.same({}, report_obj.weeks)
    end)
  end)

  describe("add_timesheet", function()
    it("should add timesheet to report", function()
      local report_obj = report_controller.create()
      local timesheet_obj = fixtures.get('timesheets.valid.with_intervals')

      report_controller.add_timesheet(report_obj, timesheet_obj)

      assert.equals(1, #report_obj.timesheets)
      assert.same(timesheet_obj, report_obj.timesheets[1])
      assert.equals(1, #report_obj.dates)
      assert.equals(timesheet_obj.date, report_obj.dates[1])
    end)

    it("should update date range when adding timesheets", function()
      local report_obj = report_controller.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      report_controller.add_timesheet(report_obj, timesheets[1])  -- 2025-04-28
      report_controller.add_timesheet(report_obj, timesheets[3])  -- 2025-05-05

      assert.equals("2025-04-28", report_obj.date_range.first)
      assert.equals("2025-05-05", report_obj.date_range.last)
    end)

    it("should update total minutes from timesheet intervals", function()
      local report_obj = report_controller.create()
      local timesheet_obj = fixtures.get('timesheets.valid.with_intervals')

      report_controller.add_timesheet(report_obj, timesheet_obj)

      assert.equals(180, report_obj.total_minutes)
    end)
  end)

  describe("calculate_summary", function()
    it("should aggregate intervals by client/project/task", function()
      local report_obj = report_controller.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        report_controller.add_timesheet(report_obj, timesheet)
      end
      report_controller.calculate_summary(report_obj)

      assert.is_true(#report_obj.summary > 0)
      -- Should have entries grouped by client/project/task
      local has_acme_planning = false
      for _, entry in ipairs(report_obj.summary) do
        if entry.client == "acme-corp" and entry.task == "planning" then
          has_acme_planning = true
        end
      end
      assert.is_true(has_acme_planning)
    end)

    it("should sort summary by client then project then task", function()
      local report_obj = report_controller.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        report_controller.add_timesheet(report_obj, timesheet)
      end
      report_controller.calculate_summary(report_obj)

      -- Verify sorting - acme-corp should come before client-x, personal
      local first_client = report_obj.summary[1].client
      assert.is_true(first_client <= report_obj.summary[#report_obj.summary].client)
    end)
  end)

  describe("get_timesheets_by_date_range", function()
    it("should return timesheets within date range", function()
      local report_obj = report_controller.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        report_controller.add_timesheet(report_obj, timesheet)
      end

      local filtered = report_controller.get_timesheets_by_date_range(report_obj, "2025-04-28", "2025-04-30")

      assert.equals(2, #filtered)  -- Should get the two April timesheets
    end)

    it("should return all timesheets when no date range specified", function()
      local report_obj = report_controller.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        report_controller.add_timesheet(report_obj, timesheet)
      end

      local all_timesheets = report_controller.get_timesheets_by_date_range(report_obj)

      assert.equals(#timesheets, #all_timesheets)
    end)
  end)

  describe("calculate_total_minutes", function()
    it("should sum minutes from all completed intervals", function()
      local report_obj = report_controller.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        report_controller.add_timesheet(report_obj, timesheet)
      end

      local total = report_controller.calculate_total_minutes(report_obj)

      -- Manual calculation: 90+45+90+120+90+210+180 = 825 minutes
      assert.equals(825, total)
    end)

    it("should ignore incomplete intervals", function()
      local report_obj = report_controller.create()
      local timesheet_complete = fixtures.get('timesheets.valid.past_day')
      local timesheet_with_open = fixtures.get('timesheets.valid.with_unclosed_intervals')
      report_controller.add_timesheet(report_obj, timesheet_complete)
      report_controller.add_timesheet(report_obj, timesheet_with_open)

      local total = report_controller.calculate_total_minutes(report_obj)

      assert.equals(45, total)  -- Only from complete timesheet
    end)
  end)

  describe("group_by_week", function()
    it("should group timesheets by week number", function()
      local report_obj = report_controller.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        report_controller.add_timesheet(report_obj, timesheet)
      end
      report_controller.group_by_week(report_obj)

      local expected_weeks = fixtures.get('reports.expected_structure.week_count')
      assert.equals(expected_weeks, #report_obj.weeks)
    end)

    it("should calculate week totals", function()
      local report_obj = report_controller.create()
      local timesheets = fixtures.get('reports.input.timesheets')

      for _, timesheet in ipairs(timesheets) do
        report_controller.add_timesheet(report_obj, timesheet)
      end
      report_controller.group_by_week(report_obj)

      assert.is_true(#report_obj.weeks > 0)
      for _, week in ipairs(report_obj.weeks) do
        assert.is_true(week.total_minutes >= 0)
      end
    end)
  end)

  describe("validate", function()
    it("should validate well-formed report", function()
      local report_obj = report_controller.create()
      local timesheet_obj = fixtures.get('timesheets.valid.with_intervals')
      report_controller.add_timesheet(report_obj, timesheet_obj)

      local is_valid, error_msg = report_controller.validate(report_obj)

      assert.is_true(is_valid)
      assert.is_nil(error_msg)
    end)

    it("should validate empty report", function()
      local empty_report = fixtures.get('reports.main_report_data.empty_report')

      local is_valid, error_msg = report_controller.validate(empty_report)

      assert.is_true(is_valid)
      assert.is_nil(error_msg)
    end)

    it("should reject report missing required fields", function()
      local invalid_report = {
        timesheets = {}
        -- missing other required fields
      }

      local is_valid, error_msg = report_controller.validate(invalid_report)

      assert.is_false(is_valid)
      assert.is_not_nil(error_msg)
    end)
  end)
end)
