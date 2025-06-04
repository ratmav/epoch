-- report_fixtures.lua
-- test fixtures for report functionality

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

-- Simple test intervals for week utils testing
report_fixtures.test_intervals = {
  simple = {
    client = "test",
    project = "test",
    task = "test",
    start = "9:00 AM",
    stop = "10:30 AM"
  }
}

-- Test timesheet structures for data loader testing
report_fixtures.test_timesheets = {
  basic_empty = {
    intervals = {},
    daily_total = "00:00"
  },

  basic_with_interval = {
    intervals = {{client = "test", project = "test", task = "test", start = "9:00 AM"}},
    daily_total = "08:00"
  },

  basic_with_interval_2 = {
    intervals = {{client = "test", project = "test", task = "test", start = "10:00 AM"}},
    daily_total = "08:00"
  }
}

-- Test summary dictionaries for summary utils testing
report_fixtures.test_summaries = {
  multi_entry_sort = {
    ["zebra|project|task"] = {client = "zebra", project = "project", task = "task", minutes = 480},
    ["alpha|project|task"] = {client = "alpha", project = "project", task = "task", minutes = 240},
    ["alpha|zebra|task"] = {client = "alpha", project = "zebra", task = "task", minutes = 120},
    ["alpha|alpha|zebra"] = {client = "alpha", project = "alpha", task = "zebra", minutes = 60},
    ["alpha|alpha|alpha"] = {client = "alpha", project = "alpha", task = "alpha", minutes = 30}
  },

  single_entry = {
    ["client|project|task"] = {client = "client", project = "project", task = "task", minutes = 480}
  },

  minutes_calculation = {
    ["entry1"] = {minutes = 480},
    ["entry2"] = {minutes = 240},
    ["entry3"] = {minutes = 120}
  },

  single_minutes = {
    ["entry1"] = {minutes = 480}
  }
}

-- Test timesheet structures for day processor testing
report_fixtures.day_processor_timesheets = {
  complete_interval = {
    date = "2025-01-01",
    intervals = {
      {
        client = "acme",
        project = "web",
        task = "dev",
        start = "9:00 AM",
        stop = "10:30 AM"
      }
    }
  },

  incomplete_interval = {
    date = "2025-01-01",
    intervals = {
      {
        client = "acme",
        project = "web",
        -- missing task
        start = "9:00 AM",
        stop = "10:30 AM"
      }
    }
  },

  multiple_intervals = {
    date = "2025-01-01",
    intervals = {
      {
        client = "acme",
        project = "web",
        task = "dev",
        start = "9:00 AM",
        stop = "10:30 AM"
      },
      {
        client = "acme",
        project = "web",
        task = "dev",
        start = "2:00 PM",
        stop = "3:00 PM"
      }
    }
  },

  no_stop_time = {
    date = "2025-01-01",
    intervals = {
      {
        client = "acme",
        project = "web",
        task = "dev",
        start = "9:00 AM"
        -- no stop time
      }
    }
  }
}

-- Test data for main report spec testing
report_fixtures.main_report_data = {
  empty_report = {
    timesheets = {},
    summary = {},
    total_minutes = 0,
    dates = {},
    weeks = {}
  }
}

-- Test data for main formatter testing
report_fixtures.formatter_data = {
  empty_report_builder_data = {weeks = {}, summary = {}, total_minutes = 0},

  report_with_weeks = {
    weeks = {
      {
        week = "2025-01",
        summary = {},
        total_minutes = 480,
        daily_totals = {},
        dates = {}
      }
    },
    summary = {},
    total_minutes = 480
  }
}

-- Test data for week_utils subdirectory testing
report_fixtures.week_utils_data = {
  complete_interval = {
    client = "test",
    project = "test",
    task = "test",
    start = "9:00 AM",
    stop = "10:30 AM"
  },

  incomplete_interval = {
    client = "test",
    project = "test",
    task = "test",
    start = "9:00 AM"
  },

  empty_stop_interval = {
    client = "test",
    project = "test",
    task = "test",
    start = "9:00 AM",
    stop = ""
  },

  invalid_time_interval = {
    client = "test",
    project = "test",
    task = "test",
    start = "invalid",
    stop = "10:30 AM"
  },

  negative_duration_interval = {
    client = "test",
    project = "test",
    task = "test",
    start = "10:30 AM",
    stop = "9:00 AM"
  },

  test_date = "2025-01-01",
  test_week_strings = {
    valid_1 = "2025-01",
    valid_2 = "2024-52",
    invalid = {"invalid", "2025", ""}
  }
}

-- Test UI mock data for report UI testing
report_fixtures.ui_mocks = {
  window_config_expectations = {
    id = "report",
    title = "epoch - report",
    width_percent = 0.5,
    height_percent = 0.6,
    filetype = "markdown",
    modifiable = false
  },

  window_close_id = "report"
}

-- Test column calculator data for table column calculator testing
report_fixtures.column_calculator_data = {
  long_names_summary = {
    {client = "very-long-client-name", project = "short", task = "medium-task", minutes = 480},
    {client = "short", project = "very-long-project-name", task = "task", minutes = 240}
  },

  short_names_summary = {
    {client = "a", project = "b", task = "c", minutes = 480}
  },

  two_column_rows = {
    {"2025-01-01", "08:00"},
    {"very-long-date-string", "10:00"}
  },

  simple_two_column_rows = {
    {"2025-01-01", "08:00"}
  },

  headers = {
    date = "Date",
    long_header = "Very Long Header"
  }
}

-- Test row builder data for table row builder testing
report_fixtures.row_builder_data = {
  column_widths = {
    client = 10,
    project = 12,
    task = 8
  },

  single_summary = {
    {client = "acme", project = "web", task = "dev", minutes = 480}
  },

  separator_line = "----------",

  test_total_minutes = 480
}

-- Test report builder data for report builder testing
report_fixtures.report_builder_data = {
  basic_report = {
    date_range = {first = "2025-01-01", last = "2025-01-07"},
    weeks = {},
    summary = {},
    total_minutes = 0
  },

  report_with_weeks = {
    weeks = {
      {
        week = "2025-01",
        date_range = {first = "2025-01-01", last = "2025-01-07"},
        daily_totals = {},
        dates = {},
        total_minutes = 480,
        summary = {}
      }
    },
    summary = {},
    total_minutes = 480
  },

  report_for_overall = {
    weeks = {
      {week = "2025-01", total_minutes = 480, summary = {}}
    },
    summary = {},
    total_minutes = 480
  },

  empty_report_data = {
    date_range = {first = "2025-01-01", last = "2025-01-07"},
    summary = {},
    total_minutes = 0
  }
}

-- Test overall summary data for overall formatter testing
report_fixtures.overall_data = {
  weeks_with_range = {
    weeks = {
      {
        week = "2025-01",
        date_range = {first = "2025-01-01", last = "2025-01-07"},
        total_minutes = 480
      }
    },
    total_minutes = 480
  },

  simple_weeks = {
    weeks = {
      {week = "2025-01", total_minutes = 480}
    },
    total_minutes = 480
  },

  client_summary = {
    summary = {
      {client = "acme", project = "web", task = "dev", minutes = 480}
    },
    total_minutes = 480
  }
}

-- Test week data for week formatter testing
report_fixtures.week_formatter_data = {
  complete_week = {
    week = "2025-01",
    date_range = {first = "2025-01-01", last = "2025-01-07"},
    daily_totals = {["2025-01-01"] = 480},
    dates = {"2025-01-01"},
    total_minutes = 480,
    summary = {
      {client = "acme", project = "web", task = "dev", minutes = 480}
    }
  },

  minimal_week = {
    week = "2025-01",
    daily_totals = {},
    dates = {},
    total_minutes = 0,
    summary = {}
  },

  week_with_daily = {
    week = "2025-01",
    daily_totals = {["2025-01-01"] = 480},
    dates = {"2025-01-01"},
    total_minutes = 480,
    summary = {}
  },

  week_with_summary = {
    week = "2025-01",
    daily_totals = {},
    dates = {},
    total_minutes = 480,
    summary = {
      {client = "acme", project = "web", task = "dev", minutes = 480}
    }
  }
}

-- Test table data for table formatter testing
report_fixtures.table_data = {
  single_summary_entry = {
    summary = {
      {client = "acme", project = "web", task = "dev", minutes = 480}
    },
    total_mins = 480
  },

  two_column_headers = {"Date", "Hours"},
  two_column_rows = {{"2025-01-01", "08:00"}},
  two_column_total_label = "TOTAL",
  two_column_total_value = "08:00"
}

-- Test daily totals data for daily formatter testing
report_fixtures.daily_totals_data = {
  two_days = {
    daily_totals = {
      ["2025-01-01"] = 480,
      ["2025-01-02"] = 520
    },
    dates = {"2025-01-01", "2025-01-02"},
    week_total_minutes = 1000
  },

  unsorted_dates = {
    daily_totals = {
      ["2025-01-02"] = 520,
      ["2025-01-01"] = 480
    },
    dates = {"2025-01-02", "2025-01-01"},
    week_total_minutes = 1000
  },

  single_day = {
    daily_totals = {
      ["2025-01-01"] = 480
    },
    dates = {"2025-01-01"},
    week_total_minutes = 480
  }
}

-- Test timesheet data for main generator testing
report_fixtures.generator_timesheets = {
  basic_with_dev_interval = {
    date = "2025-01-01",
    intervals = {
      {
        client = "acme",
        project = "web",
        task = "dev",
        start = "9:00 AM",
        stop = "10:30 AM"
      }
    },
    daily_total = "01:30"
  },

  week_15_timesheet = {
    date = "2025-01-15",
    intervals = {
      {client = "acme", project = "web", task = "dev", start = "9:00 AM", stop = "10:30 AM"}
    },
    daily_total = "01:30"
  },

  week_01_timesheet = {
    date = "2025-01-01",
    intervals = {
      {client = "acme", project = "web", task = "dev", start = "9:00 AM", stop = "10:30 AM"}
    },
    daily_total = "01:30"
  },

  first_date_timesheet = {
    date = "2025-01-01",
    intervals = {
      {client = "acme", project = "web", task = "dev", start = "9:00 AM", stop = "10:30 AM"}
    },
    daily_total = "01:30"
  },

  last_date_timesheet = {
    date = "2025-01-03",
    intervals = {
      {client = "acme", project = "web", task = "dev", start = "9:00 AM", stop = "10:30 AM"}
    },
    daily_total = "01:30"
  }
}

-- Test data structures for week processor testing
report_fixtures.week_processor_data = {
  simple_timesheets = {
    {date = "2025-01-01", intervals = {}},
    {date = "2025-01-02", intervals = {}},
    {date = "2025-01-08", intervals = {}}
  },

  single_timesheet = {
    {date = "2025-01-01", intervals = {}}
  },

  unsorted_dates = {"2025-01-03", "2025-01-01", "2025-01-02"},

  week_data_with_interval = {
    dates = {"2025-01-01"},
    timesheets = {
      {
        date = "2025-01-01",
        intervals = {
          {
            client = "acme",
            project = "web",
            task = "dev",
            start = "9:00 AM",
            stop = "10:30 AM"
          }
        }
      }
    },
    date_range = {first = "2025-01-01", last = "2025-01-07"}
  },

  week_data_for_sorting = {
    dates = {"2025-01-03", "2025-01-01", "2025-01-02"},
    timesheets = {},
    date_range = {first = "2025-01-01", last = "2025-01-07"}
  },

  week_data_for_summary = {
    dates = {"2025-01-01"},
    timesheets = {
      {
        date = "2025-01-01",
        intervals = {
          {
            client = "acme",
            project = "web",
            task = "dev",
            start = "9:00 AM",
            stop = "10:30 AM"
          }
        }
      }
    }
  }
}

-- Empty and valid report structures for formatter tests
report_fixtures.empty = {
  weeks = {},
  summary = {},
  total_minutes = 0,
  dates = {},
  date_range = {first = "2025-01-01", last = "2025-01-01"}
}

report_fixtures.valid = {
  with_data = {
    weeks = {
      {
        week = "2025-01",
        summary = {{client = "test", project = "test", task = "test", minutes = 480}},
        total_minutes = 480,
        daily_totals = {["2025-01-01"] = 480},
        dates = {"2025-01-01"}
      }
    },
    summary = {{client = "test", project = "test", task = "test", minutes = 480}},
    total_minutes = 480,
    dates = {"2025-01-01"},
    date_range = {first = "2025-01-01", last = "2025-01-01"}
  }
}

-- Sample report data structure for testing formatter
report_fixtures.sample_report_data = {
  timesheets = {},
  summary = {
    {
      client = "acme-corp",
      project = "website-redesign",
      task = "planning",
      minutes = 90
    },
    {
      client = "acme-corp",
      project = "website-redesign",
      task = "frontend-planning",
      minutes = 90
    },
    {
      client = "acme-corp",
      project = "website-redesign",
      task = "backend-planning",
      minutes = 90
    },
    {
      client = "client-x",
      project = "mobile-app",
      task = "design-review",
      minutes = 120
    },
    {
      client = "client-x",
      project = "mobile-app",
      task = "development",
      minutes = 210
    },
    {
      client = "client-y",
      project = "api-service",
      task = "documentation",
      minutes = 180
    },
    {
      client = "personal",
      project = "admin",
      task = "email",
      minutes = 45
    }
  },
  total_minutes = 825,
  dates = {"2025-04-28", "2025-04-30", "2025-05-05", "2025-05-06", "2025-05-12"},
  date_range = {
    first = "2025-04-28",
    last = "2025-05-12"
  },
  weeks = {
    {
      week = "2025-19",
      dates = {"2025-05-12"},
      summary = {
        {
          client = "client-x",
          project = "mobile-app",
          task = "development",
          minutes = 210
        },
        {
          client = "client-y",
          project = "api-service",
          task = "documentation",
          minutes = 180
        }
      },
      total_minutes = 390,
      date_range = {
        first = "2025-05-11",
        last = "2025-05-17"
      },
      daily_totals = {
        ["2025-05-12"] = 390
      }
    },
    {
      week = "2025-18",
      dates = {"2025-05-05", "2025-05-06"},
      summary = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "frontend-planning",
          minutes = 90
        },
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "backend-planning",
          minutes = 90
        },
        {
          client = "client-x",
          project = "mobile-app",
          task = "design-review",
          minutes = 120
        }
      },
      total_minutes = 300,
      date_range = {
        first = "2025-05-04",
        last = "2025-05-10"
      },
      daily_totals = {
        ["2025-05-05"] = 210,
        ["2025-05-06"] = 90
      }
    },
    {
      week = "2025-17",
      dates = {"2025-04-28", "2025-04-30"},
      summary = {
        {
          client = "acme-corp",
          project = "website-redesign",
          task = "planning",
          minutes = 90
        },
        {
          client = "personal",
          project = "admin",
          task = "email",
          minutes = 45
        }
      },
      total_minutes = 135,
      date_range = {
        first = "2025-04-27",
        last = "2025-05-03"
      },
      daily_totals = {
        ["2025-04-28"] = 90,
        ["2025-04-30"] = 45
      }
    }
  }
}

return report_fixtures