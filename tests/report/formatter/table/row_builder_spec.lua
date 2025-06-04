-- tests/report/formatter/table/row_builder_spec.lua

local row_builder = require('epoch.report.formatter.table.row_builder')

describe("report formatter table row_builder", function()
  describe("create_table_header", function()
    it("creates properly formatted header", function()
      local widths = fixtures.get('reports.row_builder_data.column_widths')
      local header = row_builder.create_table_header(widths.client, widths.project, widths.task)

      assert.is_string(header)
      assert.truthy(header:match("Client"))
      assert.truthy(header:match("Project"))
      assert.truthy(header:match("Task"))
      assert.truthy(header:match("Hours"))
    end)
  end)

  describe("create_separator_line", function()
    it("creates separator with proper width", function()
      local widths = fixtures.get('reports.row_builder_data.column_widths')
      local separator = row_builder.create_separator_line(widths.client, widths.project, widths.task)

      assert.is_string(separator)
      assert.truthy(separator:match("^%-+"))
      assert.is_true(#separator > 30)
    end)
  end)

  describe("format_data_rows", function()
    it("formats data rows into result table", function()
      local summary = fixtures.get('reports.row_builder_data.single_summary')
      local widths = fixtures.get('reports.row_builder_data.column_widths')
      local result = {}

      row_builder.format_data_rows(summary, widths.client, widths.project, widths.task, result)

      assert.equals(1, #result)
      assert.truthy(result[1]:match("acme"))
      assert.truthy(result[1]:match("web"))
      assert.truthy(result[1]:match("dev"))
      assert.truthy(result[1]:match("08:00"))
    end)
  end)

  describe("format_total_row", function()
    it("adds total row when total > 0", function()
      local result = {}
      local separator = fixtures.get('reports.row_builder_data.separator_line')
      local widths = fixtures.get('reports.row_builder_data.column_widths')
      local total = fixtures.get('reports.row_builder_data.test_total_minutes')

      row_builder.format_total_row(total, widths.client, widths.project, widths.task, separator, result)

      assert.equals(2, #result)
      assert.equals(separator, result[1])
      assert.truthy(result[2]:match("TOTAL"))
      assert.truthy(result[2]:match("08:00"))
    end)

    it("does not add total row when total is 0", function()
      local result = {}
      local separator = fixtures.get('reports.row_builder_data.separator_line')
      local widths = fixtures.get('reports.row_builder_data.column_widths')

      row_builder.format_total_row(0, widths.client, widths.project, widths.task, separator, result)

      assert.equals(0, #result)
    end)

    it("does not add total row when total is nil", function()
      local result = {}
      local separator = fixtures.get('reports.row_builder_data.separator_line')
      local widths = fixtures.get('reports.row_builder_data.column_widths')

      row_builder.format_total_row(nil, widths.client, widths.project, widths.task, separator, result)

      assert.equals(0, #result)
    end)
  end)
end)