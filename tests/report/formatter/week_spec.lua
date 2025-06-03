-- tests/report/formatter/week_spec.lua

local week_formatter = require('epoch.report.formatter.week')

describe("report formatter week", function()
  describe("format_week_section", function()
    it("formats week with date range", function()
      local week_data = {
        week = "2025-01",
        date_range = {first = "2025-01-01", last = "2025-01-07"},
        daily_totals = {["2025-01-01"] = 480},
        dates = {"2025-01-01"},
        total_minutes = 480,
        summary = {
          {client = "acme", project = "web", task = "dev", minutes = 480}
        }
      }
      
      local result = week_formatter.format_week_section(week_data)
      
      assert.is_table(result)
      assert.truthy(result[1]:match("## Week of"))
      assert.truthy(result[1]:match("2025%-01%-01"))
      assert.truthy(result[1]:match("2025%-01%-07"))
    end)
    
    it("formats week without date range", function()
      local week_data = {
        week = "2025-01",
        daily_totals = {},
        dates = {},
        total_minutes = 0,
        summary = {}
      }
      
      local result = week_formatter.format_week_section(week_data)
      
      assert.is_table(result)
      assert.truthy(result[1]:match("## Week 2025%-01"))
    end)
    
    it("includes daily totals section", function()
      local week_data = {
        week = "2025-01",
        daily_totals = {["2025-01-01"] = 480},
        dates = {"2025-01-01"},
        total_minutes = 480,
        summary = {}
      }
      
      local result = week_formatter.format_week_section(week_data)
      
      local found_daily = false
      for _, line in ipairs(result) do
        if line:match("### By Day") then
          found_daily = true
          break
        end
      end
      
      assert.is_true(found_daily)
    end)
    
    it("includes client summary section", function()
      local week_data = {
        week = "2025-01",
        daily_totals = {},
        dates = {},
        total_minutes = 480,
        summary = {
          {client = "acme", project = "web", task = "dev", minutes = 480}
        }
      }
      
      local result = week_formatter.format_week_section(week_data)
      
      local found_client = false
      for _, line in ipairs(result) do
        if line:match("### By Client") then
          found_client = true
          break
        end
      end
      
      assert.is_true(found_client)
    end)
  end)
end)