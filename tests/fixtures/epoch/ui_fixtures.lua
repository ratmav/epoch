-- ui_fixtures.lua
-- test fixtures for UI testing (data only)

-- Create a module for UI test fixtures
local ui_fixtures = {}

-- Fixed window configuration matching requirements
ui_fixtures.window_config = {
  width_percentage = 0.4,  -- 40% width
  height_percentage = 0.8, -- 80% height
  style = 'minimal',
  border = 'rounded',
  title_pos = "center",
}

-- Expected notification message patterns
ui_fixtures.notification_patterns = {
  validation_error = "^epoch: validation error",   -- Pattern for validation errors
  timesheet_saved = "^epoch: timesheet saved$",    -- Pattern for save success
  time_tracking = "^epoch: time tracking started", -- Pattern for interval start
}

-- Sample buffer content for testing
ui_fixtures.buffer_content = {
  -- A valid timesheet buffer content
  valid_timesheet = [[return {
  ["date"] = "2025-05-12",
  ["intervals"] = {
    {
      ["client"] = "acme-corp",
      ["project"] = "website-redesign",
      ["task"] = "frontend-planning",
      ["start"] = "09:00 AM",
      ["stop"] = "10:30 AM",
      ["notes"] = {},
    },
    {
      ["client"] = "acme-corp",
      ["project"] = "website-redesign",
      ["task"] = "backend-planning",
      ["start"] = "10:45 AM",
      ["stop"] = "12:15 PM",
      ["notes"] = {},
    },
  },
  ["daily_total"] = "03:00",
}]],

  -- A timesheet buffer with invalid time format
  invalid_time_format = [[return {
  ["date"] = "2025-05-12",
  ["intervals"] = {
    {
      ["client"] = "acme-corp",
      ["project"] = "website-redesign",
      ["task"] = "frontend-planning",
      ["start"] = "9:00", -- Missing AM/PM
      ["stop"] = "10:30 AM",
      ["notes"] = {},
    },
  },
  ["daily_total"] = "01:30",
}]],

  -- A timesheet buffer with missing required field
  missing_field = [[return {
  ["date"] = "2025-05-12",
  ["intervals"] = {
    {
      ["client"] = "acme-corp",
      -- Missing project field
      ["task"] = "frontend-planning",
      ["start"] = "09:00 AM",
      ["stop"] = "10:30 AM",
    },
  },
  ["daily_total"] = "01:30",
}]],

  -- A timesheet buffer with overlapping intervals
  overlapping_intervals = [[return {
  ["date"] = "2025-05-12",
  ["intervals"] = {
    {
      ["client"] = "acme-corp",
      ["project"] = "website-redesign",
      ["task"] = "frontend-planning",
      ["start"] = "09:00 AM",
      ["stop"] = "10:30 AM",
      ["notes"] = {},
    },
    {
      ["client"] = "acme-corp",
      ["project"] = "website-redesign",
      ["task"] = "backend-planning",
      ["start"] = "10:00 AM", -- Overlaps with previous interval
      ["stop"] = "11:00 AM",
      ["notes"] = {},
    },
  },
  ["daily_total"] = "02:30",
}]],

  -- Invalid Lua syntax
  invalid_syntax = [[return {
  ["date"] = "2025-05-12",
  ["intervals"] = {
    {
      ["client"] = "acme-corp",
      ["project"] = "website-redesign",
      ["task"] = "frontend-planning",
      ["start"] = "09:00 AM",
      ["stop"] = "10:30 AM",
      ["notes"] = {},
    }, -- Missing closing brace
  ["daily_total"] = "01:30",
}]],
}

return ui_fixtures