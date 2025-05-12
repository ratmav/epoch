-- tests/report/formatter/overall_spec.lua

local overall = require('epoch.report.formatter.overall')

describe("report formatter overall", function()
  describe("format_overall_weeks_section", function()
    it("formats weeks summary with headers", function()
      local data = fixtures.get('reports.overall_data.weeks_with_range')
      local weeks = data.weeks
      local total_minutes = data.total_minutes

      local result = overall.format_overall_weeks_section(weeks, total_minutes)

      assert.is_table(result)
      assert.truthy(result[1]:match("## Overall By Week"))
      assert.truthy(result[3]:match("Week"))
      assert.truthy(result[3]:match("Hours"))
    end)

    it("includes total row", function()
      local data = fixtures.get('reports.overall_data.simple_weeks')
      local weeks = data.weeks
      local total_minutes = data.total_minutes

      local result = overall.format_overall_weeks_section(weeks, total_minutes)

      local found_total = false
      for _, line in ipairs(result) do
        if line:match("TOTAL") then
          found_total = true
          break
        end
      end

      assert.is_true(found_total)
    end)
  end)

  describe("format_overall_clients_section", function()
    it("formats client summary with headers", function()
      local data = fixtures.get('reports.overall_data.client_summary')
      local summary = data.summary
      local total_minutes = data.total_minutes

      local result = overall.format_overall_clients_section(summary, total_minutes)

      assert.is_table(result)
      assert.truthy(result[1]:match("## Overall By Client"))
    end)

    it("handles empty summary", function()
      local result = overall.format_overall_clients_section({}, 0)

      assert.is_table(result)
      assert.truthy(result[1]:match("## Overall By Client"))
    end)
  end)
end)