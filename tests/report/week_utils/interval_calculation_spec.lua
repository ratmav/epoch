-- tests/report/week_utils/interval_calculation_spec.lua

local interval_calculation = require('epoch.report.week_utils.interval_calculation')

describe("report week_utils interval_calculation", function()
  describe("calculate_interval_minutes", function()
    it("calculates minutes for complete intervals", function()
      local interval = {
        client = "test",
        project = "test", 
        task = "test",
        start = "9:00 AM",
        stop = "10:30 AM"
      }
      local date = "2025-01-01"
      
      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(90, minutes)
    end)
    
    it("returns 0 for incomplete intervals", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test", 
        start = "9:00 AM"
      }
      local date = "2025-01-01"
      
      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(0, minutes)
    end)
    
    it("returns 0 for intervals with empty stop time", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "9:00 AM",
        stop = ""
      }
      local date = "2025-01-01"
      
      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(0, minutes)
    end)
    
    it("returns 0 for intervals with invalid time formats", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "invalid",
        stop = "10:30 AM"
      }
      local date = "2025-01-01"
      
      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(0, minutes)
    end)
    
    it("handles negative durations by returning 0", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "10:30 AM",
        stop = "9:00 AM"
      }
      local date = "2025-01-01"
      
      local minutes = interval_calculation.calculate_interval_minutes(interval, date)
      assert.equals(0, minutes)
    end)
  end)
end)