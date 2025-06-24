-- tests/time_utils/parsing_spec.lua

local parsing = require('epoch.time.parsing')

describe("time_utils parsing", function()
  describe("time_to_seconds", function()
    it("converts valid time and date to timestamp", function()
      local valid_times = fixtures.get('time.parsing.valid_times')
      for _, test_case in ipairs(valid_times) do
        local timestamp = parsing.time_to_seconds(test_case.time, test_case.date)
        local expected = os.time({
          year=2025, month=1, day=1,
          hour=test_case.expected_hour,
          min=test_case.expected_min
        })
        assert.equals(expected, timestamp)
      end
    end)

    it("handles 12 AM and 12 PM correctly", function()
      local edge_cases = fixtures.get('time.parsing.twelve_hour_edge_cases')
      for _, test_case in ipairs(edge_cases) do
        local timestamp = parsing.time_to_seconds(test_case.time, test_case.date)
        local expected = os.time({
          year=2025, month=1, day=1,
          hour=test_case.expected_hour,
          min=test_case.expected_min
        })
        assert.equals(expected, timestamp)
      end
    end)

    it("returns nil for invalid time format", function()
      local invalid_times = fixtures.get('time.parsing.invalid_time_formats')
      for _, invalid_time in ipairs(invalid_times) do
        assert.is_nil(parsing.time_to_seconds(invalid_time, "2025-01-01"))
      end
    end)

    it("returns nil for invalid date format", function()
      local invalid_dates = fixtures.get('time.parsing.invalid_date_formats')
      for _, invalid_date in ipairs(invalid_dates) do
        assert.is_nil(parsing.time_to_seconds("9:30 AM", invalid_date))
      end
    end)
  end)

  describe("parse_time", function()
    it("parses time string using today's date", function()
      local test_data = fixtures.get('time.parsing.parse_time_test')
      local today = os.date("*t")
      local timestamp = parsing.parse_time(test_data.time)
      local expected = os.time({
        year=today.year,
        month=today.month,
        day=today.day,
        hour=test_data.expected_hour,
        min=test_data.expected_min
      })

      assert.equals(expected, timestamp)
    end)

    it("returns nil for invalid time format", function()
      local invalid_times = fixtures.get('time.parsing.parse_time_invalid')
      for _, invalid_time in ipairs(invalid_times) do
        assert.is_nil(parsing.parse_time(invalid_time))
      end
    end)
  end)
end)