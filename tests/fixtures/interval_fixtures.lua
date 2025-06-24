-- interval_fixtures.lua
-- Simple static test fixtures for interval operations

return {
  -- Valid intervals
  valid = {
    frontend = {
      client = "acme-corp",
      project = "website-redesign",
      task = "frontend-planning",
      start = "09:00 AM",
      stop = "10:30 AM",
      hours = 1.5,
      notes = {}
    },

    backend = {
      client = "acme-corp",
      project = "website-redesign",
      task = "backend-planning",
      start = "10:45 AM",
      stop = "12:15 PM",
      hours = 1.5,
      notes = {}
    },

    personal = {
      client = "personal",
      project = "admin",
      task = "email",
      start = "08:30 AM",
      stop = "09:15 AM",
      hours = 0.75,
      notes = {}
    },

    with_notes = {
      client = "acme-corp",
      project = "website-redesign",
      task = "documentation",
      start = "01:00 PM",
      stop = "03:00 PM",
      hours = 2.0,
      notes = {"Added API documentation", "Reviewed with team"}
    }
  },

  -- Test intervals for context generation
  test = {
    partial = {
      client = "test-client",
      project = "test-project"
    },

    complete = {
      client = "client",
      project = "project",
      task = "task",
      start = "10:00 AM"
    }
  },

  -- Invalid intervals
  invalid = {
    missing_client = {
      client = nil,
      project = "website-redesign",
      task = "frontend-planning",
      start = "09:00 AM",
      stop = "10:30 AM",
      notes = {}
    },

    missing_project = {
      client = "acme-corp",
      project = nil,
      task = "frontend-planning",
      start = "09:00 AM",
      stop = "10:30 AM",
      notes = {}
    },

    missing_task = {
      client = "acme-corp",
      project = "website-redesign",
      task = nil,
      start = "09:00 AM",
      stop = "10:30 AM",
      notes = {}
    },

    missing_notes = {
      client = "acme-corp",
      project = "website-redesign",
      task = "frontend-planning",
      start = "09:00 AM",
      stop = "10:30 AM",
      notes = nil
    },

    invalid_notes_type = {
      client = "acme-corp",
      project = "website-redesign",
      task = "frontend-planning",
      start = "09:00 AM",
      stop = "10:30 AM",
      notes = "This should be an array, not a string"
    },

    invalid_notes_entries = {
      client = "acme-corp",
      project = "website-redesign",
      task = "frontend-planning",
      start = "09:00 AM",
      stop = "10:30 AM",
      notes = {1, 2, 3}  -- Numbers instead of strings
    },

    invalid_time = {
      client = "acme-corp",
      project = "website-redesign",
      task = "frontend-planning",
      start = "9:00",  -- Missing AM/PM
      stop = "10:30 AM",
      notes = {}
    },

    unclosed = {
      client = "acme-corp",
      project = "website-redesign",
      task = "frontend-planning",
      start = "09:00 AM",
      stop = "",  -- Explicitly empty stop time
      notes = {}
    },

    overlapping = {
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
        start = "10:00 AM",  -- Overlaps with first interval
        stop = "12:00 PM",
        notes = {}
      }
    },

    overlapping_unclosed = {
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
        start = "10:15 AM",  -- Starts before frontend stop time
        stop = "",           -- Unclosed
        notes = {}
      }
    }
  },

  -- Example intervals for specific test scenarios
  examples = {
    morning_work = {
      client = "personal",
      project = "admin",
      task = "email",
      start = "08:30 AM",
      stop = "09:15 AM",
      notes = {}
    },

    evening_work = {
      client = "side-project",
      project = "website",
      task = "blog-post",
      start = "07:00 PM",
      stop = "08:30 PM",
      notes = {}
    }
  },

  -- Test data for serializer testing
  serializer = {
    no_stop_time = {
      client = "test",
      project = "test",
      task = "test",
      start = "9:00 AM"
      -- stop is nil/missing
    }
  }
}