-- report_fixtures.lua
-- test fixtures for report functionality

local interval_fixtures = require('tests.fixtures.interval_fixtures')
local time_fixtures = require('tests.fixtures.time_fixtures')
local timesheet_helpers = require('tests.helpers.timesheet_helpers')

local report_fixtures = {}

-- Create a set of timesheets for testing report generation
-- We use static dates rather than relative ones to ensure consistent test results
report_fixtures.input = {
  -- Data representing multiple weeks/days
  timesheets = {
    -- April week - Week 17
    {
      date = "2025-04-28", -- Monday
      intervals = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "planning",
          start = "09:00 AM",
          stop = "10:30 AM",
        }
      }
    },
    {
      date = "2025-04-30", -- Wednesday
      intervals = {
        {
          client = "personal",
          project = "admin",
          task = "email",
          start = "08:30 AM",
          stop = "09:15 AM",
        }
      }
    },
    
    -- May week 1 - Week 18
    {
      date = "2025-05-05", -- Monday
      intervals = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "frontend-planning",
          start = "09:00 AM",
          stop = "10:30 AM",
        },
        {
          client = "client-x",
          project = "mobile-app",
          task = "design-review",
          start = "02:00 PM",
          stop = "04:00 PM",
        }
      }
    },
    {
      date = "2025-05-06", -- Tuesday
      intervals = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "backend-planning",
          start = "10:45 AM",
          stop = "12:15 PM",
        }
      }
    },
    
    -- May week 2 - Week 19
    {
      date = "2025-05-12", -- Monday
      intervals = {
        {
          client = "client-x",
          project = "mobile-app",
          task = "development",
          start = "08:30 AM",
          stop = "12:00 PM",
        },
        {
          client = "client-y",
          project = "api-service",
          task = "documentation",
          start = "01:30 PM",
          stop = "04:30 PM",
        }
      }
    }
  }
}

-- Expected report structure after processing the above timesheets
report_fixtures.expected_structure = {
  -- We expect 3 weeks in the data
  week_count = 3,
  
  -- Latest week should be first
  first_week = "2025-19", -- Week 19 (May 12-18)
  
  -- Check client distribution
  clients = {
    "acme-corp",
    "client-x",
    "client-y",
    "personal"
  },
  
  -- Each week should have its own dates
  weeks = {
    {
      week = "2025-19", -- Week 19
      dates = {"2025-05-12"},
      date_range = {
        first = "2025-05-11", -- Sunday
        last = "2025-05-17"   -- Saturday
      },
      clients = {"client-x", "client-y"},
      total_minutes = 390     -- 6.5 hours
    },
    {
      week = "2025-18", -- Week 18
      dates = {"2025-05-05", "2025-05-06"},
      date_range = {
        first = "2025-05-04", -- Sunday
        last = "2025-05-10"   -- Saturday
      },
      clients = {"acme-corp", "client-x"},
      total_minutes = 240     -- 4 hours
    },
    {
      week = "2025-17", -- Week 17
      dates = {"2025-04-28", "2025-04-30"},
      date_range = {
        first = "2025-04-27", -- Sunday
        last = "2025-05-03"   -- Saturday
      },
      clients = {"acme-corp", "personal"},
      total_minutes = 135     -- 2.25 hours
    }
  },
  
  -- Overall totals
  total_minutes = 765 -- 12.75 hours
}

-- Expected report output format (with appropriate patterns for flexible matching)
report_fixtures.expected_output = [[
Period: 2025-04-28 to 2025-05-12

## Week of 2025-05-11 to 2025-05-17

### By Day

Date         Hours
------------ ------
2025-05-12   06:30
------------ ------
TOTAL        06:30

### By Client

Client    Project     Task          Hours
--------- ----------- ------------- ------
client-x  mobile-app  development   03:30
client-y  api-service documentation 03:00
--------- ----------- ------------- ------
TOTAL                               06:30


## Week of 2025-05-04 to 2025-05-10

### By Day

Date         Hours
------------ ------
2025-05-05   03:30
2025-05-06   01:30
------------ ------
TOTAL        05:00

### By Client

Client     Project          Task             Hours
---------- --------------- ---------------- ------
acme-corp  website-redesign backend-planning  01:30
acme-corp  website-redesign frontend-planning 01:30
client-x   mobile-app      design-review    02:00
---------- --------------- ---------------- ------
TOTAL                                        05:00


## Week of 2025-04-27 to 2025-05-03

### By Day

Date         Hours
------------ ------
2025-04-28   01:30
2025-04-30   00:45
------------ ------
TOTAL        02:15

### By Client

Client     Project          Task     Hours
---------- --------------- -------- ------
acme-corp  website-redesign planning 01:30
personal   admin           email    00:45
---------- --------------- -------- ------
TOTAL                               02:15


## Overall By Week

Week             Hours
---------------- ------
Week 2025-05-11  06:30
Week 2025-05-04  05:00
Week 2025-04-27  02:15
---------------- ------
TOTAL            13:45

## Overall By Client

Client     Project          Task             Hours
---------- --------------- ---------------- ------
acme-corp  website-redesign backend-planning  01:30
acme-corp  website-redesign frontend-planning 01:30
acme-corp  website-redesign planning         01:30
client-x   mobile-app      design-review    02:00
client-x   mobile-app      development      03:30
client-y   api-service     documentation    03:00
personal   admin           email            00:45
---------- --------------- ---------------- ------
TOTAL                                        13:45]]

-- Create a pattern-based version of the output for flexible testing
report_fixtures.expected_patterns = {
  -- Header
  "Period: %d%d%d%d%-%d%d%-%d%d to %d%d%d%d%-%d%d%-%d%d",
  
  -- Latest week first (Week 19)
  "## Week of 2025%-05%-11 to 2025%-05%-17",
  
  -- Week 18
  "## Week of 2025%-05%-04 to 2025%-05%-10",
  
  -- Week 17
  "## Week of 2025%-04%-27 to 2025%-05%-03",
  
  -- Section headers
  "### By Day",
  "### By Client",
  "## Overall By Week",
  "## Overall By Client",
  
  -- Client names (in any order)
  "acme%-corp",
  "client%-x",
  "client%-y",
  "personal",
  
  -- Project names
  "website%-redesign",
  "mobile%-app",
  "api%-service",
  "admin",
  
  -- Task names
  "planning",
  "frontend%-planning",
  "backend%-planning",
  "design%-review",
  "development",
  "documentation",
  "email",
  
  -- Table headers
  "Date%s+Hours",
  "Client%s+Project%s+Task%s+Hours",
  "Week%s+Hours",
  
  -- Footer totals
  "TOTAL%s+13:45"
}

return report_fixtures