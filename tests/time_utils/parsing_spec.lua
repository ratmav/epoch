-- tests/time_utils/parsing_spec.lua

local parsing = require('epoch.time_utils.parsing')

describe("time_utils parsing", function()
  describe("time_to_seconds", function()
    it("converts valid time and date to timestamp", function()
      local timestamp = parsing.time_to_seconds("9:30 AM", "2025-01-01")
      local expected = os.time({year=2025, month=1, day=1, hour=9, min=30})
      
      assert.equals(expected, timestamp)
    end)
    
    it("handles PM times correctly", function()
      local timestamp = parsing.time_to_seconds("2:45 PM", "2025-01-01")
      local expected = os.time({year=2025, month=1, day=1, hour=14, min=45})
      
      assert.equals(expected, timestamp)
    end)
    
    it("handles 12 AM and 12 PM correctly", function()
      local midnight = parsing.time_to_seconds("12:00 AM", "2025-01-01")
      local noon = parsing.time_to_seconds("12:00 PM", "2025-01-01")
      
      local expected_midnight = os.time({year=2025, month=1, day=1, hour=0, min=0})
      local expected_noon = os.time({year=2025, month=1, day=1, hour=12, min=0})
      
      assert.equals(expected_midnight, midnight)
      assert.equals(expected_noon, noon)
    end)
    
    it("returns nil for invalid time format", function()
      assert.is_nil(parsing.time_to_seconds("25:00 AM", "2025-01-01"))
      assert.is_nil(parsing.time_to_seconds("invalid", "2025-01-01"))
    end)
    
    it("returns nil for invalid date format", function()
      assert.is_nil(parsing.time_to_seconds("9:30 AM", "invalid-date"))
      assert.is_nil(parsing.time_to_seconds("9:30 AM", "not-a-date"))
    end)
  end)
  
  describe("parse_time", function()
    it("parses time string using today's date", function()
      local today = os.date("*t")
      local timestamp = parsing.parse_time("9:30 AM")
      local expected = os.time({
        year=today.year, 
        month=today.month, 
        day=today.day, 
        hour=9, 
        min=30
      })
      
      assert.equals(expected, timestamp)
    end)
    
    it("returns nil for invalid time format", function()
      assert.is_nil(parsing.parse_time("25:00 AM"))
      assert.is_nil(parsing.parse_time("invalid"))
      assert.is_nil(parsing.parse_time(nil))
    end)
  end)
end)