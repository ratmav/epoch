-- time_fixtures.lua
-- test fixtures for time operations

return {
  -- time format samples (12-hour format with AM/PM)
  time_strings = {
    valid = {
      morning = "09:30 AM",
      noon = "12:00 PM",
      afternoon = "02:45 PM",
      evening = "07:15 PM",
      midnight = "12:00 AM",
      late_night = "01:30 AM"
    },
    invalid = {
      wrong_format = "9:30",
      missing_period = "09:30",
      wrong_separator = "09-30 AM",
      invalid_hour = "13:30 AM",
      invalid_minute = "09:60 AM"
    }
  },

  -- sample date strings (YYYY-MM-DD)
  dates = {
    valid = {
      today = "2025-05-12",
      past = "2025-05-01",
      future = "2025-05-20"
    },
    invalid = {
      wrong_format = "05/12/2025",
      invalid_month = "2025-13-01",
      invalid_day = "2025-05-32"
    }
  },

  -- sample durations (in minutes)
  durations = {
    thirty_min = 30,
    one_hour = 60,
    one_hour_thirty = 90,
    two_hours = 120,
    eight_hours = 480
  },

  -- fixed timestamps for testing (avoiding os.time() for deterministic tests)
  timestamps = {
    base_time = 1748930760,  -- Fixed base timestamp
    two_hours_later = 1748937960,  -- base_time + 7200 seconds (2 hours)
    morning_9am = 1748930400,  -- Represents 9:00 AM on test date
    afternoon_2pm = 1748948400  -- Represents 2:00 PM on test date
  },

  -- Time format validation test data
  validation = {
    valid_formats = {
      "9:00 AM",
      "12:00 PM",
      "11:59 PM",
      "12:00 AM",
      "6:30 PM"
    },

    invalid_formats = {
      "25:00 AM",
      "12:60 PM",
      "0:30 AM",
      "13:00 PM",
      "9:00",
      "9 AM",
      "",
      nil
    },

    invalid_spacing_case = {
      "9:00AM",
      "9:00 am",
      "9:00  AM"
    }
  },

  -- Duration formatting test data
  duration = {
    minutes_to_format = {
      {minutes = 0, expected = "00:00"},
      {minutes = 30, expected = "00:30"},
      {minutes = 60, expected = "01:00"},
      {minutes = 90, expected = "01:30"},
      {minutes = 135, expected = "02:15"},
      {minutes = 1440, expected = "24:00"}
    },

    invalid_inputs = {
      {input = nil, expected = "00:00"},
      {input = -30, expected = "00:00"}
    }
  },

  -- Timestamp formatting test data
  format_timestamps = {
    morning = os.time({year=2025, month=1, day=1, hour=9, min=30}),
    afternoon = os.time({year=2025, month=1, day=1, hour=14, min=45}),
    midnight = os.time({year=2025, month=1, day=1, hour=0, min=0}),
    noon = os.time({year=2025, month=1, day=1, hour=12, min=0})
  },

  -- Time parsing test data
  parsing = {
    valid_times = {
      {time = "9:30 AM", date = "2025-01-01", expected_hour = 9, expected_min = 30},
      {time = "2:45 PM", date = "2025-01-01", expected_hour = 14, expected_min = 45}
    },

    twelve_hour_edge_cases = {
      {time = "12:00 AM", date = "2025-01-01", expected_hour = 0, expected_min = 0},
      {time = "12:00 PM", date = "2025-01-01", expected_hour = 12, expected_min = 0}
    },

    invalid_time_formats = {
      "25:00 AM",
      "invalid"
    },

    invalid_date_formats = {
      "invalid-date",
      "not-a-date"
    },

    parse_time_test = {
      time = "9:30 AM",
      expected_hour = 9,
      expected_min = 30
    },

    parse_time_invalid = {
      "25:00 AM",
      "invalid",
      nil
    }
  },

  -- Common date arrays for testing
  date_arrays = {
    storage_test_dates = {"2025-05-10", "2025-05-11", "2025-05-12"},
    generator_test_dates = {"2025-01-01", "2025-01-03", "2025-01-02"},
    sorted_generator_dates = {"2025-01-01", "2025-01-02"},
    simple_range = {"2025-01-01", "2025-01-02", "2025-01-03"}
  }
}