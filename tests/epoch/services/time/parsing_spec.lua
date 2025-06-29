-- tests/epoch/services/time/parsing_spec.lua

local parsing = require('epoch.services.time.parsing')

describe("services time parsing", function()
  describe("parse_time_components", function()
    it("should parse valid 12-hour time format", function()
      local hour, minute, period = parsing.parse_time_components("9:30 AM")
      
      assert.equals(9, hour)
      assert.equals(30, minute)
      assert.equals("AM", period)
    end)

    it("should parse different time formats", function()
      local hour, minute, period = parsing.parse_time_components("12:00 PM")
      
      assert.equals(12, hour)
      assert.equals(0, minute)
      assert.equals("PM", period)
    end)

    it("should return nil for invalid format", function()
      local hour, minute, period = parsing.parse_time_components("invalid")
      
      assert.is_nil(hour)
      assert.is_nil(minute)
      assert.is_nil(period)
    end)

    it("should return nil for missing AM/PM", function()
      local hour, minute, period = parsing.parse_time_components("9:30")
      
      assert.is_nil(hour)
      assert.is_nil(minute)
      assert.is_nil(period)
    end)
  end)

  describe("validate_time_ranges", function()
    it("should validate correct hour and minute ranges", function()
      assert.is_true(parsing.validate_time_ranges(9, 30))
      assert.is_true(parsing.validate_time_ranges(12, 0))
      assert.is_true(parsing.validate_time_ranges(1, 59))
    end)

    it("should reject invalid hour values", function()
      assert.is_false(parsing.validate_time_ranges(0, 30))
      assert.is_false(parsing.validate_time_ranges(13, 30))
    end)

    it("should reject invalid minute values", function()
      assert.is_false(parsing.validate_time_ranges(9, 60))
      assert.is_false(parsing.validate_time_ranges(9, -1))
    end)
  end)

  describe("parse_date_components", function()
    it("should parse valid YYYY-MM-DD format", function()
      local year, month, day = parsing.parse_date_components("2025-01-15")
      
      assert.equals(2025, year)
      assert.equals(1, month)
      assert.equals(15, day)
    end)

    it("should return nil for invalid format", function()
      local year, month, day = parsing.parse_date_components("invalid-date")
      
      assert.is_nil(year)
      assert.is_nil(month)
      assert.is_nil(day)
    end)

    it("should return nil for wrong separator", function()
      local year, month, day = parsing.parse_date_components("2025/01/15")
      
      assert.is_nil(year)
      assert.is_nil(month)
      assert.is_nil(day)
    end)
  end)
end)