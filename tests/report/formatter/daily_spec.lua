-- tests/report/formatter/daily_spec.lua

local daily_formatter = require('epoch.report.formatter.daily')

describe("report formatter daily", function()
  describe("format_daily_section", function()
    it("formats daily totals with proper headers", function()
      local daily_totals = {
        ["2025-01-01"] = 480,
        ["2025-01-02"] = 520
      }
      local dates = {"2025-01-01", "2025-01-02"}
      local week_total_minutes = 1000
      
      local result = daily_formatter.format_daily_section(daily_totals, dates, week_total_minutes)
      
      assert.is_table(result)
      assert.truthy(result[1]:match("### By Day"))
      assert.truthy(result[3]:match("Date"))
      assert.truthy(result[3]:match("Hours"))
    end)
    
    it("sorts dates chronologically", function()
      local daily_totals = {
        ["2025-01-02"] = 520,
        ["2025-01-01"] = 480
      }
      local dates = {"2025-01-02", "2025-01-01"}
      local week_total_minutes = 1000
      
      local result = daily_formatter.format_daily_section(daily_totals, dates, week_total_minutes)
      
      local found_2025_01_01 = false
      local found_2025_01_02 = false
      local pos_01_01, pos_01_02
      
      for i, line in ipairs(result) do
        if line:match("2025%-01%-01") then
          found_2025_01_01 = true
          pos_01_01 = i
        elseif line:match("2025%-01%-02") then
          found_2025_01_02 = true
          pos_01_02 = i
        end
      end
      
      assert.is_true(found_2025_01_01)
      assert.is_true(found_2025_01_02)
      assert.is_true(pos_01_01 < pos_01_02)
    end)
    
    it("handles empty data gracefully", function()
      local result = daily_formatter.format_daily_section(nil, nil, 0)
      
      assert.is_table(result)
      assert.truthy(result[1]:match("No daily totals"))
    end)
    
    it("includes total row", function()
      local daily_totals = {
        ["2025-01-01"] = 480
      }
      local dates = {"2025-01-01"}
      local week_total_minutes = 480
      
      local result = daily_formatter.format_daily_section(daily_totals, dates, week_total_minutes)
      
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
end)