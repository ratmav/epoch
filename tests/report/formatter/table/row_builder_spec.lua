-- tests/report/formatter/table/row_builder_spec.lua

local row_builder = require('epoch.report.formatter.table.row_builder')

describe("report formatter table row_builder", function()
  describe("create_table_header", function()
    it("creates properly formatted header", function()
      local header = row_builder.create_table_header(10, 12, 8)
      
      assert.is_string(header)
      assert.truthy(header:match("Client"))
      assert.truthy(header:match("Project"))
      assert.truthy(header:match("Task"))
      assert.truthy(header:match("Hours"))
    end)
  end)
  
  describe("create_separator_line", function()
    it("creates separator with proper width", function()
      local separator = row_builder.create_separator_line(10, 12, 8)
      
      assert.is_string(separator)
      assert.truthy(separator:match("^%-+"))
      assert.is_true(#separator > 30)
    end)
  end)
  
  describe("format_data_rows", function()
    it("formats data rows into result table", function()
      local summary = {
        {client = "acme", project = "web", task = "dev", minutes = 480}
      }
      local result = {}
      
      row_builder.format_data_rows(summary, 10, 12, 8, result)
      
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
      local separator = "----------"
      
      row_builder.format_total_row(480, 10, 12, 8, separator, result)
      
      assert.equals(2, #result)
      assert.equals(separator, result[1])
      assert.truthy(result[2]:match("TOTAL"))
      assert.truthy(result[2]:match("08:00"))
    end)
    
    it("does not add total row when total is 0", function()
      local result = {}
      local separator = "----------"
      
      row_builder.format_total_row(0, 10, 12, 8, separator, result)
      
      assert.equals(0, #result)
    end)
    
    it("does not add total row when total is nil", function()
      local result = {}
      local separator = "----------"
      
      row_builder.format_total_row(nil, 10, 12, 8, separator, result)
      
      assert.equals(0, #result)
    end)
  end)
end)