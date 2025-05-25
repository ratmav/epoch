-- timesheet_fixtures.lua
-- test fixtures for timesheet operations

local interval_fixtures = require('tests.fixtures.interval_fixtures')
local time_fixtures = require('tests.fixtures.time_fixtures')
local timesheet_helpers = require('tests.helpers.timesheet_helpers')

-- Use the helper functions from timesheet_helpers
local create_timesheet = timesheet_helpers.create_timesheet
local calculate_daily_total = timesheet_helpers.calculate_daily_total

-- Pre-calculated timesheets
local valid_timesheets = {
  empty = create_timesheet(time_fixtures.dates.valid.today, {}),

  with_intervals = create_timesheet(
    time_fixtures.dates.valid.today,
    interval_fixtures.valid,
    calculate_daily_total(interval_fixtures.valid)
  ),

  past_day = create_timesheet(
    time_fixtures.dates.valid.past,
    {interval_fixtures.base.personal},
    "00:45"
  ),

  -- Timesheet with only unclosed intervals (should have zero total time)
  with_unclosed_intervals = {
    date = time_fixtures.dates.valid.today,
    intervals = {
      {
        client = "test-client",
        project = "test-project",
        task = "test-task",
        start = "09:00 AM",
        stop = "",  -- Explicitly empty stop time
        notes = {}  -- Empty notes array
      }
    },
    daily_total = "00:00"
  }
}

-- Create properly invalid timesheets
local invalid_missing_date = create_timesheet(time_fixtures.dates.valid.today, interval_fixtures.valid)
invalid_missing_date.date = nil

local invalid_missing_intervals = create_timesheet(time_fixtures.dates.valid.today)
invalid_missing_intervals.intervals = nil

local invalid_interval = create_timesheet(
  time_fixtures.dates.valid.today,
  {
    interval_fixtures.valid[1],
    interval_fixtures.invalid.missing_client
  }
)

return {
  -- Valid timesheets
  valid = valid_timesheets,
  
  -- Invalid timesheets
  invalid = {
    missing_date = invalid_missing_date,
    missing_intervals = invalid_missing_intervals,
    invalid_interval = invalid_interval,
    
    overlapping_intervals = create_timesheet(
      time_fixtures.dates.valid.today,
      interval_fixtures.invalid.overlapping,
      "03:00"
    )
  },
  
  -- Function to create custom timesheets for tests
  create = create_timesheet
}