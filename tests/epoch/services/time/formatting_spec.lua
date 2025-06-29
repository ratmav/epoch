-- tests/epoch/services/time/formatting_spec.lua

local formatting = require('epoch.services.time.formatting')

describe("services time formatting", function()
  describe("format_current_time", function()
    it("should format timestamp to 12-hour time", function()
      -- Test with known timestamp: 2025-01-01 09:30:00
      local timestamp = os.time({year=2025, month=1, day=1, hour=9, min=30, sec=0})
      
      local formatted = formatting.format_current_time(timestamp)
      
      assert.equals("9:30 AM", formatted)
    end)

    it("should format PM times correctly", function()
      -- Test with known timestamp: 2025-01-01 15:45:00
      local timestamp = os.time({year=2025, month=1, day=1, hour=15, min=45, sec=0})
      
      local formatted = formatting.format_current_time(timestamp)
      
      assert.equals("3:45 PM", formatted)
    end)

    it("should format midnight correctly", function()
      -- Test with known timestamp: 2025-01-01 00:00:00
      local timestamp = os.time({year=2025, month=1, day=1, hour=0, min=0, sec=0})
      
      local formatted = formatting.format_current_time(timestamp)
      
      assert.equals("12:00 AM", formatted)
    end)
  end)

  describe("format_duration", function()
    it("should format minutes to HH:MM", function()
      assert.equals("01:30", formatting.format_duration(90))
      assert.equals("02:15", formatting.format_duration(135))
      assert.equals("00:45", formatting.format_duration(45))
    end)

    it("should handle zero and negative values", function()
      assert.equals("00:00", formatting.format_duration(0))
      assert.equals("00:00", formatting.format_duration(-30))
    end)

    it("should handle large durations", function()
      assert.equals("24:00", formatting.format_duration(1440))
      assert.equals("25:30", formatting.format_duration(1530))
    end)
  end)

  describe("parse_to_timestamp", function()
    it("should parse time with date to timestamp", function()
      local timestamp = formatting.parse_to_timestamp("9:30 AM", "2025-01-01")
      local expected = os.time({year=2025, month=1, day=1, hour=9, min=30, sec=0})
      
      assert.equals(expected, timestamp)
    end)

    it("should handle PM times", function()
      local timestamp = formatting.parse_to_timestamp("3:45 PM", "2025-01-01")
      local expected = os.time({year=2025, month=1, day=1, hour=15, min=45, sec=0})
      
      assert.equals(expected, timestamp)
    end)

    it("should return nil for invalid input", function()
      assert.is_nil(formatting.parse_to_timestamp("invalid", "2025-01-01"))
      assert.is_nil(formatting.parse_to_timestamp("9:30 AM", "invalid-date"))
    end)
  end)
end)