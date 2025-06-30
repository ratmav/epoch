-- tests/report/formatter/report_builder_spec.lua

local report_builder = require('epoch.report.formatter.report_builder')

describe("report formatter report_builder", function()
  describe("build_report_lines", function()
    it("builds report with period header", function()
      local report_data = fixtures.get('reports.report_builder_data.basic_report')

      local result = report_builder.build_report_lines(report_data)

      assert.is_table(result)
      assert.truthy(result[1]:match("Period:"))
      assert.truthy(result[1]:match("2025%-01%-01"))
      assert.truthy(result[1]:match("2025%-01%-07"))
    end)

    it("includes week sections", function()
      local report_data = fixtures.get('reports.report_builder_data.report_with_weeks')

      local result = report_builder.build_report_lines(report_data)

      local found_week = false
      for _, line in ipairs(result) do
        if line:match("## Week of") then
          found_week = true
          break
        end
      end

      assert.is_true(found_week)
    end)

    it("includes overall summaries when weeks exist", function()
      local report_data = fixtures.get('reports.report_builder_data.report_for_overall')

      local result = report_builder.build_report_lines(report_data)

      local found_overall_weeks = false
      local found_overall_clients = false

      for _, line in ipairs(result) do
        if line:match("## Overall By Week") then
          found_overall_weeks = true
        elseif line:match("## Overall By Client") then
          found_overall_clients = true
        end
      end

      assert.is_true(found_overall_weeks)
      assert.is_true(found_overall_clients)
    end)
  end)

  describe("format_empty_report", function()
    it("formats empty report with period header", function()
      local report_data = fixtures.get('reports.report_builder_data.empty_report_data')

      local result = report_builder.format_empty_report(report_data)

      assert.is_string(result)
      assert.truthy(result:match("Period:"))
      assert.truthy(result:match("## Overall By Client"))
    end)
  end)
end)