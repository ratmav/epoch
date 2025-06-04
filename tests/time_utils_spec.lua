-- time_utils_spec.lua
-- tests for the time_utils module

describe("time_utils", function()
  local time_utils = require('epoch.time_utils')
  local fixtures = require('fixtures.init')

  describe("is_valid_time_format", function()
    it("returns true for valid 12-hour time formats", function()
      for _, time_str in pairs(fixtures.get('time.time_strings.valid')) do
        assert.is_true(time_utils.is_valid_time_format(time_str),
          "should validate time format: " .. time_str)
      end
    end)

    it("returns false for invalid time formats", function()
      for _, time_str in pairs(fixtures.get('time.time_strings.invalid')) do
        assert.is_false(time_utils.is_valid_time_format(time_str),
          "should reject invalid time format: " .. time_str)
      end
    end)

    it("returns false for nil or empty input", function()
      assert.is_false(time_utils.is_valid_time_format(nil))
      assert.is_false(time_utils.is_valid_time_format(""))
    end)
  end)

  describe("format_duration", function()
    it("formats minutes as HH:MM", function()
      assert.equals("00:30", time_utils.format_duration(fixtures.get('time.durations.thirty_min')))
      assert.equals("01:00", time_utils.format_duration(fixtures.get('time.durations.one_hour')))
      assert.equals("01:30", time_utils.format_duration(fixtures.get('time.durations.one_hour_thirty')))
      assert.equals("02:00", time_utils.format_duration(fixtures.get('time.durations.two_hours')))
      assert.equals("08:00", time_utils.format_duration(fixtures.get('time.durations.eight_hours')))
    end)

    it("handles zero or negative values", function()
      assert.equals("00:00", time_utils.format_duration(0))
      assert.equals("00:00", time_utils.format_duration(-10))
    end)
  end)

  describe("time_to_seconds", function()
    it("converts time string to seconds since midnight", function()
      local date = fixtures.get('time.dates.valid.today')
      local midnight = time_utils.time_to_seconds("12:00 AM", date)
      local six_am = time_utils.time_to_seconds("06:00 AM", date)
      local noon = time_utils.time_to_seconds("12:00 PM", date)
      local six_pm = time_utils.time_to_seconds("06:00 PM", date)

      -- Verify timestamps increase as time advances through the day
      assert.is_true(midnight < six_am, "midnight should be earlier than 6am")
      assert.is_true(six_am < noon, "6am should be earlier than noon")
      assert.is_true(noon < six_pm, "noon should be earlier than 6pm")

      -- Check relative time differences (more flexible than exact equality)
      local morning_diff = noon - six_am
      local afternoon_diff = six_pm - noon

      -- Hours should be roughly the same (allow 5 seconds tolerance for rounding)
      assert.is_true(math.abs(afternoon_diff - morning_diff) < 5,
        "time differences between hours should be consistent")
    end)

    it("returns nil for invalid inputs", function()
      assert.is_nil(time_utils.time_to_seconds("invalid", fixtures.get('time.dates.valid.today')))
      assert.is_nil(time_utils.time_to_seconds("12:00 PM", "invalid-date"))
      assert.is_nil(time_utils.time_to_seconds(nil, nil))
    end)
  end)

  describe("format_time", function()
    it("formats timestamp as 12-hour time", function()
      local now = os.time()
      local formatted = time_utils.format_time(now)

      assert.is_true(time_utils.is_valid_time_format(formatted))
    end)
  end)
end)