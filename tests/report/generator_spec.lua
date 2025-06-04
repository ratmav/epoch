-- tests/report/generator_spec.lua

local generator = require('epoch.report.generator')
local storage = require('epoch.storage')

describe("report generator", function()
  -- Set up a test data directory for isolation
  before_each(function()
    storage.set_data_dir("/tmp/epoch_test_data")
    vim.fn.mkdir("/tmp/epoch_test_data", "p")
    vim.fn.system("rm -f /tmp/epoch_test_data/*.lua")
  end)

  -- Clean up after tests
  after_each(function()
    vim.fn.system("rm -rf /tmp/epoch_test_data")
  end)

  describe("get_all_timesheet_dates", function()
    it("delegates to data loader", function()
      local dates = generator.get_all_timesheet_dates()

      assert.is_table(dates)
    end)
  end)

  describe("generate_report", function()
    it("returns empty report when no timesheets exist", function()
      local report = generator.generate_report()

      assert.is_table(report)
      assert.same({}, report.timesheets)
      assert.same({}, report.summary)
      assert.equals(0, report.total_minutes)
      assert.same({}, report.weeks)
    end)

    it("generates report with timesheet data", function()
      local timesheet = fixtures.get('reports.generator_timesheets.basic_with_dev_interval')
      storage.save_timesheet(timesheet)

      local report = generator.generate_report()

      assert.is_table(report)
      assert.equals(1, #report.timesheets)
      assert.is_true(#report.summary > 0)
      assert.equals(90, report.total_minutes)
      assert.is_true(#report.weeks > 0)
      assert.truthy(report.date_range)
      assert.equals("2025-01-01", report.date_range.first)
      assert.equals("2025-01-01", report.date_range.last)
    end)

    it("sorts weeks chronologically", function()
      -- Create timesheets in different weeks
      storage.save_timesheet(fixtures.get('reports.generator_timesheets.week_15_timesheet'))
      storage.save_timesheet(fixtures.get('reports.generator_timesheets.week_01_timesheet'))

      local report = generator.generate_report()

      assert.is_true(#report.weeks >= 1)
      -- Weeks should be sorted in descending order (newest first)
      if #report.weeks > 1 then
        assert.is_true(report.weeks[1].week >= report.weeks[2].week)
      end
    end)

    it("includes date range for multiple dates", function()
      storage.save_timesheet(fixtures.get('reports.generator_timesheets.first_date_timesheet'))
      storage.save_timesheet(fixtures.get('reports.generator_timesheets.last_date_timesheet'))

      local report = generator.generate_report()

      assert.truthy(report.date_range)
      assert.equals("2025-01-01", report.date_range.first)
      assert.equals("2025-01-03", report.date_range.last)
    end)
  end)
end)