-- tests/time_utils/formatting_spec.lua

local formatting = require('epoch.time_utils.formatting')

describe("time_utils formatting", function()
  describe("format_duration", function()
    it("formats minutes as HH:MM", function()
      assert.equals("00:00", formatting.format_duration(0))
      assert.equals("00:30", formatting.format_duration(30))
      assert.equals("01:00", formatting.format_duration(60))
      assert.equals("01:30", formatting.format_duration(90))
      assert.equals("02:15", formatting.format_duration(135))
      assert.equals("24:00", formatting.format_duration(1440))
    end)
    
    it("handles invalid inputs", function()
      assert.equals("00:00", formatting.format_duration(nil))
      assert.equals("00:00", formatting.format_duration(-30))
    end)
  end)
  
  describe("format_time", function()
    it("formats timestamp as h:MM AM/PM", function()
      -- Test specific known timestamps
      local morning = os.time({year=2025, month=1, day=1, hour=9, min=30})
      local afternoon = os.time({year=2025, month=1, day=1, hour=14, min=45})
      local midnight = os.time({year=2025, month=1, day=1, hour=0, min=0})
      local noon = os.time({year=2025, month=1, day=1, hour=12, min=0})
      
      assert.equals("09:30 AM", formatting.format_time(morning))
      assert.equals("02:45 PM", formatting.format_time(afternoon))
      assert.equals("12:00 AM", formatting.format_time(midnight))
      assert.equals("12:00 PM", formatting.format_time(noon))
    end)
  end)
end)