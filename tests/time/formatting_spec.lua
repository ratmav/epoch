-- tests/time_utils/formatting_spec.lua

local formatting = require('epoch.time.formatting')

describe("time_utils formatting", function()
  describe("format_duration", function()
    it("formats minutes as HH:MM", function()
      local test_cases = fixtures.get('time.duration.minutes_to_format')
      for _, test_case in ipairs(test_cases) do
        assert.equals(test_case.expected, formatting.format_duration(test_case.minutes))
      end
    end)

    it("handles invalid inputs", function()
      local invalid_cases = fixtures.get('time.duration.invalid_inputs')
      for _, test_case in ipairs(invalid_cases) do
        assert.equals(test_case.expected, formatting.format_duration(test_case.input))
      end
    end)
  end)

  describe("format_time", function()
    it("formats timestamp as h:MM AM/PM", function()
      local timestamps = fixtures.get('time.format_timestamps')

      assert.equals("09:30 AM", formatting.format_time(timestamps.morning))
      assert.equals("02:45 PM", formatting.format_time(timestamps.afternoon))
      assert.equals("12:00 AM", formatting.format_time(timestamps.midnight))
      assert.equals("12:00 PM", formatting.format_time(timestamps.noon))
    end)
  end)
end)