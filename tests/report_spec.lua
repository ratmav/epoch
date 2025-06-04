-- report_spec.lua
-- tests for the report module

describe("report", function()
  local report = require('epoch.report')

  describe("format_report", function()
    it("formats a report with all expected sections and patterns", function()
      -- Generate report data directly from our fixtures
      local report_data = fixtures.get('reports.sample_report_data')

      -- Format the report using the actual formatter
      local formatted = report.format_report(report_data)

      -- Check that the report contains all expected patterns
      for _, pattern in ipairs(fixtures.get('reports.expected_patterns')) do
        assert.is_not_nil(
          formatted:match(pattern),
          "Report should match pattern: " .. pattern
        )
      end

      -- Verify proper ordering of weeks (most recent first)
      local week19_pos = formatted:find("Week of 2025%-05%-11")
      local week18_pos = formatted:find("Week of 2025%-05%-04")
      local week17_pos = formatted:find("Week of 2025%-04%-27")

      assert.is_not_nil(week19_pos)
      assert.is_not_nil(week18_pos)
      assert.is_not_nil(week17_pos)

      assert.is_true(week19_pos < week18_pos, "Week 19 should appear before Week 18")
      assert.is_true(week18_pos < week17_pos, "Week 18 should appear before Week 17")

      -- Verify the overall by week section exists and has correct ordering
      local overall_section = formatted:find("## Overall By Week")
      assert.is_not_nil(overall_section, "Report should contain 'Overall By Week' section")

      -- Verify all weeks appear in the overall section
      local overall_week19 = formatted:find("Week 2025%-05%-11", overall_section)
      local overall_week18 = formatted:find("Week 2025%-05%-04", overall_section)
      local overall_week17 = formatted:find("Week 2025%-04%-27", overall_section)

      assert.is_not_nil(overall_week19)
      assert.is_not_nil(overall_week18)
      assert.is_not_nil(overall_week17)

      assert.is_true(overall_week19 < overall_week18, "Week 19 should appear before Week 18 in Overall section")
      assert.is_true(overall_week18 < overall_week17, "Week 18 should appear before Week 17 in Overall section")
    end)

    it("handles empty data gracefully", function()
      local empty_report = fixtures.get('reports.main_report_data.empty_report')

      local formatted = report.format_report(empty_report)

      assert.is_not_nil(formatted)
      assert.is_true(#formatted > 0)
      assert.is_not_nil(formatted:match("## Overall By Client"))
      assert.is_not_nil(formatted:match("No time entries found for this period"))
    end)
  end)
end)