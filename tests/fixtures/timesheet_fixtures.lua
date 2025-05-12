-- timesheet_fixtures.lua
-- Simple static test fixtures for timesheet operations

return {
  -- Valid timesheets
  valid = {
    empty = {
      date = "2025-05-28",
      intervals = {},
      daily_total = "00:00"
    },

    with_intervals = {
      date = "2025-05-28",
      intervals = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "frontend-planning",
          start = "09:00 AM",
          stop = "10:30 AM",
          notes = {}
        },
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "backend-planning",
          start = "10:45 AM",
          stop = "12:15 PM",
          notes = {}
        }
      },
      daily_total = "03:00"
    },

    past_day = {
      date = "2025-05-27",
      intervals = {
        {
          client = "personal",
          project = "admin",
          task = "email",
          start = "08:30 AM",
          stop = "09:15 AM",
          notes = {}
        }
      },
      daily_total = "00:45"
    },

    with_unclosed_intervals = {
      date = "2025-05-28",
      intervals = {
        {
          client = "test-client",
          project = "test-project",
          task = "test-task",
          start = "09:00 AM",
          stop = "",  -- Explicitly empty stop time
          notes = {}
        }
      },
      daily_total = "00:00"
    },


    unsorted_intervals = {
      date = "2025-05-12",
      intervals = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "backend-planning",
          start = "10:45 AM",
          stop = "12:15 PM",
          notes = {}
        },
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "frontend-planning",
          start = "09:00 AM",
          stop = "10:30 AM",
          notes = {}
        }
      },
      daily_total = "03:00"
    },

    with_interval_with_notes = {
      date = "2025-05-12",
      intervals = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "documentation",
          start = "01:00 PM",
          stop = "03:00 PM",
          notes = {"Added API documentation", "Reviewed with team"}
        }
      },
      daily_total = "02:00"
    },

    timing_conflict_unclosed = {
      date = "2025-05-28",
      intervals = {
        {
          client = "test-client",
          project = "test-project",
          task = "test-task",
          start = "09:00 AM",
          stop = "",  -- Unclosed for timing conflict testing
          notes = {}
        }
      },
      daily_total = "00:00"
    }
  },

  -- Invalid timesheets
  invalid = {
    missing_date = {
      date = nil,
      intervals = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "frontend-planning",
          start = "09:00 AM",
          stop = "10:30 AM",
          notes = {}
        }
      },
      daily_total = "01:30"
    },

    missing_intervals = {
      date = "2025-05-28",
      intervals = nil,
      daily_total = "00:00"
    },

    invalid_interval = {
      date = "2025-05-28",
      intervals = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "frontend-planning",
          start = "09:00 AM",
          stop = "10:30 AM",
          notes = {}
        },
        {
          client = nil,  -- Invalid: missing client
          project = "website-redesign",
          task = "frontend-planning",
          start = "09:00 AM",
          stop = "10:30 AM",
          notes = {}
        }
      },
      daily_total = "03:00"
    },

    with_unclosed_interval_no_notes = {
      date = "2025-05-28",
      intervals = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "frontend-planning",
          start = "09:00 AM",
          stop = ""
          -- Missing notes field intentionally for testing
        }
      },
      daily_total = "00:00"
    }
  },

  -- Storage test timesheets
  storage = {
    single_interval = {
      date = "2025-01-01",
      intervals = {
        {client = "test", project = "test", task = "test", start = "9:00 AM"}
      },
      daily_total = "00:00"
    },

    mixed_intervals = {
      date = "2025-01-01",
      intervals = {
        {client = "test", project = "test", task = "test", start = "9:00 AM"},
        {client = "test", project = "test", task = "test"}
      },
      daily_total = "00:00"
    },

    incomplete_interval = {
      intervals = {
        {client = "test"}  -- Missing required fields
      }
    }
  }
}