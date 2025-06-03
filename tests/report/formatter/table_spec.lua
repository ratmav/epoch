-- tests/report/formatter/table_spec.lua

local table_formatter = require('epoch.report.formatter.table')

describe("report formatter table", function()
  describe("format_summary_table", function()
    it("formats summary table with headers", function()
      local summary = {
        {client = "acme", project = "web", task = "dev", minutes = 480}
      }
      local total_mins = 480
      
      local result = table_formatter.format_summary_table(summary, total_mins)
      
      assert.is_table(result)
      assert.truthy(result[1]:match("Client"))
      assert.truthy(result[1]:match("Project"))
      assert.truthy(result[1]:match("Task"))
      assert.truthy(result[1]:match("Hours"))
    end)
    
    it("includes separator lines", function()
      local summary = {
        {client = "acme", project = "web", task = "dev", minutes = 480}
      }
      local total_mins = 480
      
      local result = table_formatter.format_summary_table(summary, total_mins)
      
      local has_separator = false
      for _, line in ipairs(result) do
        if line:match("^%-+") then
          has_separator = true
          break
        end
      end
      
      assert.is_true(has_separator)
    end)
    
    it("handles empty summary", function()
      local result = table_formatter.format_summary_table({}, 0)
      
      assert.is_table(result)
      assert.truthy(result[1]:match("No time entries"))
    end)
  end)
  
  describe("format_two_column_table", function()
    it("formats two column table with headers", function()
      local headers = {"Date", "Hours"}
      local rows = {{"2025-01-01", "08:00"}}
      local total_label = "TOTAL"
      local total_value = "08:00"
      
      local result = table_formatter.format_two_column_table(headers, rows, total_label, total_value)
      
      assert.is_table(result)
      assert.truthy(result[1]:match("Date"))
      assert.truthy(result[1]:match("Hours"))
    end)
    
    it("includes total row when provided", function()
      local headers = {"Date", "Hours"}
      local rows = {{"2025-01-01", "08:00"}}
      local total_label = "TOTAL"
      local total_value = "08:00"
      
      local result = table_formatter.format_two_column_table(headers, rows, total_label, total_value)
      
      local found_total = false
      for _, line in ipairs(result) do
        if line:match("TOTAL") then
          found_total = true
          break
        end
      end
      
      assert.is_true(found_total)
    end)
    
    it("handles no total", function()
      local headers = {"Date", "Hours"}
      local rows = {{"2025-01-01", "08:00"}}
      
      local result = table_formatter.format_two_column_table(headers, rows)
      
      assert.is_table(result)
      assert.is_true(#result >= 3)
    end)
  end)
end)