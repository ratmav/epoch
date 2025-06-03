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
  }
}