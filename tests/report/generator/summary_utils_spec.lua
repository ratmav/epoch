-- tests/report/generator/summary_utils_spec.lua

local summary_utils = require('epoch.report.generator.summary_utils')

describe("report generator summary_utils", function()
  describe("sort_summary", function()
    it("sorts summary by client, project, task", function()
      local summary_dict = fixtures.get('reports.test_summaries.multi_entry_sort')

      local result = summary_utils.sort_summary(summary_dict)

      assert.equals(5, #result)
      assert.equals("alpha", result[1].client)
      assert.equals("alpha", result[1].project)
      assert.equals("alpha", result[1].task)

      assert.equals("alpha", result[2].client)
      assert.equals("alpha", result[2].project)
      assert.equals("zebra", result[2].task)

      assert.equals("zebra", result[5].client)
    end)

    it("handles empty summary", function()
      local result = summary_utils.sort_summary({})

      assert.same({}, result)
    end)

    it("converts dictionary to array", function()
      local summary_dict = fixtures.get('reports.test_summaries.single_entry')

      local result = summary_utils.sort_summary(summary_dict)

      assert.equals(1, #result)
      assert.equals("client", result[1].client)
      assert.equals("project", result[1].project)
      assert.equals("task", result[1].task)
      assert.equals(8.0, result[1].hours)
    end)
  end)

  describe("calculate_total_hours", function()
    it("sums hours from all entries", function()
      local summary_dict = fixtures.get('reports.test_summaries.hours_calculation')

      local result = summary_utils.calculate_total_hours(summary_dict)

      assert.equals(14.0, result)
    end)

    it("returns 0 for empty summary", function()
      local result = summary_utils.calculate_total_hours({})

      assert.equals(0, result)
    end)

    it("handles single entry", function()
      local summary_dict = fixtures.get('reports.test_summaries.single_hours')

      local result = summary_utils.calculate_total_hours(summary_dict)

      assert.equals(8.0, result)
    end)
  end)
end)