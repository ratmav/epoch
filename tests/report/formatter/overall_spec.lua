-- tests/report/formatter/overall_spec.lua

local overall = require('epoch.report.formatter.overall')

describe("report formatter overall", function()
  describe("format_overall_weeks_section", function()
    it("formats weeks summary with headers", function()
      local weeks = {
        {
          week = "2025-01",
          date_range = {first = "2025-01-01", last = "2025-01-07"},
          total_minutes = 480
        }
      }
      local total_minutes = 480
      
      local result = overall.format_overall_weeks_section(weeks, total_minutes)
      
      assert.is_table(result)
      assert.truthy(result[1]:match("## Overall By Week"))
      assert.truthy(result[3]:match("Week"))
      assert.truthy(result[3]:match("Hours"))
    end)
    
    it("includes total row", function()
      local weeks = {
        {week = "2025-01", total_minutes = 480}
      }
      local total_minutes = 480
      
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
      local summary = {
        {client = "acme", project = "web", task = "dev", minutes = 480}
      }
      local total_minutes = 480
      
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