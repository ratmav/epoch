-- interval_fixtures.lua
-- test fixtures for interval operations

local time_fixtures = require('tests.fixtures.time_fixtures')
local interval_helpers = require('tests.helpers.interval_helpers')

-- Base interval templates to derive from
local base_intervals = {
  frontend = {
    client = "acme-corp",
    project = "website-redesign",
    task = "frontend-planning",
    start = "09:00 AM",
    stop = "10:30 AM",
  },
  
  backend = {
    client = "acme-corp",
    project = "website-redesign",
    task = "backend-planning",
    start = "10:45 AM",
    stop = "12:15 PM",
  },
  
  personal = {
    client = "personal",
    project = "admin",
    task = "email",
    start = "08:30 AM",
    stop = "09:15 AM",
  }
}

-- Use the derive_interval function from interval_helpers
local derive_interval = interval_helpers.derive_interval

-- Create invalid intervals with proper nil values
local missing_client = derive_interval(base_intervals.frontend, {})
missing_client.client = nil

local missing_project = derive_interval(base_intervals.frontend, {})
missing_project.project = nil

local missing_task = derive_interval(base_intervals.frontend, {})
missing_task.task = nil

return {
  -- Sample intervals
  valid = {
    base_intervals.frontend,
    base_intervals.backend,
  },
  
  invalid = {
    -- Missing required fields
    missing_client = missing_client,
    missing_project = missing_project,
    missing_task = missing_task,
    
    -- Invalid time format
    invalid_time = derive_interval(base_intervals.frontend, {start = "9:00"}),
    
    -- Overlapping intervals
    overlapping = {
      base_intervals.frontend,
      derive_interval(base_intervals.backend, {start = "10:00 AM"})
    },
    
    -- Unclosed interval that would overlap with an existing interval
    overlapping_unclosed = {
      base_intervals.frontend,  -- 9:00 AM to 10:30 AM
      derive_interval(base_intervals.backend, {
        start = "10:15 AM",  -- Starts before frontend stop time
        stop = ""         -- No stop time
      })
    },
    
    -- Unclosed interval that doesn't overlap (for comparison)
    non_overlapping_unclosed = {
      base_intervals.frontend,  -- 9:00 AM to 10:30 AM
      derive_interval(base_intervals.backend, {
        start = "10:45 AM",  -- Starts after frontend stop time
        stop = ""         -- No stop time
      })
    },
    
    -- Unclosed interval
    unclosed = derive_interval(base_intervals.frontend, {stop = ""}),
  },
  
  examples = {
    morning_work = base_intervals.personal,
    
    evening_work = {
      client = "side-project",
      project = "website",
      task = "blog-post",
      start = "07:00 PM",
      stop = "08:30 PM",
    }
  },
  
  -- Export the base intervals too for direct use
  base = base_intervals
}