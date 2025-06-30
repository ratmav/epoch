-- tests/report/formatter/table/column_calculator_spec.lua

local column_calculator = require('epoch.report.formatter.table.column_calculator')

describe("report formatter table column_calculator", function()
  describe("calculate_column_widths", function()
    it("returns minimum header widths for empty summary", function()
      local max_client, max_project, max_task = column_calculator.calculate_column_widths({})

      assert.equals(6, max_client)   -- "Client"
      assert.equals(7, max_project)  -- "Project"
      assert.equals(4, max_task)     -- "Task"
    end)

    it("calculates widths based on data", function()
      local summary = fixtures.get('reports.column_calculator_data.long_names_summary')

      local max_client, max_project, max_task = column_calculator.calculate_column_widths(summary)

      assert.equals(21, max_client)   -- "very-long-client-name"
      assert.equals(22, max_project)  -- "very-long-project-name"
      assert.equals(11, max_task)     -- "medium-task"
    end)

    it("uses header width when data is shorter", function()
      local summary = fixtures.get('reports.column_calculator_data.short_names_summary')

      local max_client, max_project, max_task = column_calculator.calculate_column_widths(summary)

      assert.equals(6, max_client)   -- "Client" > "a"
      assert.equals(7, max_project)  -- "Project" > "b"
      assert.equals(4, max_task)     -- "Task" > "c"
    end)
  end)

  describe("calculate_two_column_width", function()
    it("returns minimum width based on header", function()
      local header = fixtures.get('reports.column_calculator_data.headers.date')
      local width = column_calculator.calculate_two_column_width(header, {})

      assert.equals(12, width)  -- Minimum is 12
    end)

    it("calculates width based on data", function()
      local rows = fixtures.get('reports.column_calculator_data.two_column_rows')
      local header = fixtures.get('reports.column_calculator_data.headers.date')

      local width = column_calculator.calculate_two_column_width(header, rows)

      assert.equals(21, width)  -- "very-long-date-string"
    end)

    it("uses header width when larger than data", function()
      local rows = fixtures.get('reports.column_calculator_data.simple_two_column_rows')
      local header = fixtures.get('reports.column_calculator_data.headers.long_header')

      local width = column_calculator.calculate_two_column_width(header, rows)

      assert.equals(16, width)  -- "Very Long Header"
    end)
  end)
end)