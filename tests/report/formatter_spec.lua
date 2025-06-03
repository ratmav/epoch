-- tests/report/formatter_spec.lua

local formatter = require('epoch.report.formatter')
local fixtures = require('tests.fixtures')

describe("report formatter", function()
  describe("format_report", function()
    it("formats empty report when no weeks exist", function()
      local report_data = fixtures.get("reports.empty")
      local result = formatter.format_report(report_data)
      
      assert.is_string(result)
      assert.is_true(#result > 0)
    end)
    
    it("formats report with weeks data", function()
      local report_data = fixtures.get("reports.valid.with_data")
      local result = formatter.format_report(report_data)
      
      assert.is_string(result)
      assert.is_true(#result > 0)
    end)
    
    it("delegates to report_builder for empty reports", function()
      local report_data = {weeks = {}, summary = {}, total_minutes = 0}
      local result = formatter.format_report(report_data)
      
      assert.is_string(result)
      assert.truthy(result:match("Overall By Client"))
    end)
    
    it("delegates to report_builder for reports with data", function()
      local report_data = {
        weeks = {
          {
            week = "2025-01",
            summary = {},
            total_minutes = 480,
            daily_totals = {},
            dates = {}
          }
        },
        summary = {},
        total_minutes = 480
      }
      local result = formatter.format_report(report_data)
      
      assert.is_string(result)
      assert.truthy(result:match("Week"))
    end)
  end)
end)