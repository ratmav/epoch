-- tests/services/time_spec.lua

local time_service = require('epoch.services.time')

describe("services time", function()
  describe("is_valid_format", function()
    it("should validate correct 12-hour time formats", function()
      assert.is_true(time_service.is_valid_format("9:00 AM"))
      assert.is_true(time_service.is_valid_format("12:30 PM"))
      assert.is_true(time_service.is_valid_format("1:15 AM"))
      assert.is_true(time_service.is_valid_format("11:59 PM"))
    end)

    it("should reject invalid time formats", function()
      assert.is_false(time_service.is_valid_format("9:00"))
      assert.is_false(time_service.is_valid_format("25:00 AM"))
      assert.is_false(time_service.is_valid_format("9:60 AM"))
      assert.is_false(time_service.is_valid_format("invalid"))
      assert.is_false(time_service.is_valid_format(""))
      assert.is_false(time_service.is_valid_format(nil))
    end)
  end)

  describe("to_minutes_since_midnight", function()
    it("should convert time strings to minutes since midnight", function()
      assert.equals(0, time_service.to_minutes_since_midnight("12:00 AM"))
      assert.equals(60, time_service.to_minutes_since_midnight("1:00 AM"))
      assert.equals(540, time_service.to_minutes_since_midnight("9:00 AM"))
      assert.equals(720, time_service.to_minutes_since_midnight("12:00 PM"))
      assert.equals(780, time_service.to_minutes_since_midnight("1:00 PM"))
      assert.equals(1439, time_service.to_minutes_since_midnight("11:59 PM"))
    end)

    it("should return nil for invalid time formats", function()
      assert.is_nil(time_service.to_minutes_since_midnight("invalid"))
      assert.is_nil(time_service.to_minutes_since_midnight("25:00 AM"))
      assert.is_nil(time_service.to_minutes_since_midnight(""))
      assert.is_nil(time_service.to_minutes_since_midnight(nil))
    end)
  end)

  describe("format_current_time", function()
    it("should format current timestamp to 12-hour format", function()
      local formatted = time_service.format_current_time()

      assert.is_not_nil(formatted)
      assert.is_true(time_service.is_valid_format(formatted))
    end)

    it("should accept custom timestamp", function()
      -- January 1, 2025, 9:30 AM
      local timestamp = os.time({year = 2025, month = 1, day = 1, hour = 9, min = 30})
      local formatted = time_service.format_current_time(timestamp)

      assert.equals("9:30 AM", formatted)
    end)
  end)

  describe("format_duration", function()
    it("should format minutes as HH:MM", function()
      assert.equals("00:00", time_service.format_duration(0))
      assert.equals("01:30", time_service.format_duration(90))
      assert.equals("08:00", time_service.format_duration(480))
      assert.equals("12:45", time_service.format_duration(765))
    end)

    it("should handle negative values as zero", function()
      assert.equals("00:00", time_service.format_duration(-30))
    end)
  end)

  describe("parse_to_timestamp", function()
    it("should parse time string with date to timestamp", function()
      local timestamp = time_service.parse_to_timestamp("9:30 AM", "2025-01-01")
      local expected = os.time({year = 2025, month = 1, day = 1, hour = 9, min = 30})

      assert.equals(expected, timestamp)
    end)

    it("should use today's date when no date provided", function()
      local timestamp = time_service.parse_to_timestamp("9:30 AM")
      local today = os.date("*t")
      local expected = os.time({
        year = today.year,
        month = today.month,
        day = today.day,
        hour = 9,
        min = 30
      })

      assert.equals(expected, timestamp)
    end)

    it("should return nil for invalid inputs", function()
      assert.is_nil(time_service.parse_to_timestamp("invalid", "2025-01-01"))
      assert.is_nil(time_service.parse_to_timestamp("9:30 AM", "invalid-date"))
    end)
  end)
end)
