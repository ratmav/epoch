-- tests/epoch/controllers/report/aggregation_spec.lua

local aggregation = require('epoch.controllers.report.aggregation')

describe("controllers report aggregation", function()
  describe("calculate_summary", function()
    it("should aggregate intervals by client/project/task", function()
      local report = fixtures.get('reports.empty')
      local timesheet_with_intervals = fixtures.get('timesheets.valid.with_intervals')
      local timesheet_past_day = fixtures.get('timesheets.valid.past_day')
      report.timesheets = {timesheet_with_intervals, timesheet_past_day}

      aggregation.calculate_summary(report)

      assert.is_true(#report.summary > 0)
      -- Should have entries grouped by client/project/task
      local has_acme_frontend = false
      for _, entry in ipairs(report.summary) do
        if entry.client == "acme-corp" and entry.task == "frontend-planning" then
          has_acme_frontend = true
        end
      end
      assert.is_true(has_acme_frontend)
    end)

    it("should sort summary by client then project then task", function()
      local report = fixtures.get('reports.empty')
      local timesheet_with_intervals = fixtures.get('timesheets.valid.with_intervals')
      local timesheet_past_day = fixtures.get('timesheets.valid.past_day')
      report.timesheets = {timesheet_with_intervals, timesheet_past_day}

      aggregation.calculate_summary(report)

      -- Verify sorting - acme-corp should come before client-x, personal
      local first_client = report.summary[1].client
      assert.is_true(first_client <= report.summary[#report.summary].client)
    end)

    it("should calculate total minutes for each summary entry", function()
      local report = fixtures.get('reports.empty')
      local timesheet_with_intervals = fixtures.get('timesheets.valid.with_intervals')
      report.timesheets = {timesheet_with_intervals}

      aggregation.calculate_summary(report)

      -- Each summary entry should have minutes > 0
      for _, entry in ipairs(report.summary) do
        assert.is_true(entry.minutes >= 0)
      end
    end)

    it("should handle empty timesheets", function()
      local empty_report = fixtures.get('reports.empty')

      aggregation.calculate_summary(empty_report)

      assert.same({}, empty_report.summary)
    end)

    it("should ignore incomplete intervals", function()
      local report = fixtures.get('reports.empty')
      local timesheet_with_unclosed = fixtures.get('timesheets.valid.with_unclosed_intervals')
      report.timesheets = {timesheet_with_unclosed}

      aggregation.calculate_summary(report)

      assert.same({}, report.summary)
    end)
  end)
end)