-- epoch/factory.lua
-- Data structure factory for consistent object creation across the application

local factory = {}

-- Build report data structure with configurable parameters
function factory.build_report(opts)
  opts = opts or {}

  return {
    timesheets = opts.timesheets or {},
    summary = opts.summary or {},
    total_minutes = opts.total_minutes or 0,
    dates = opts.dates or {},
    weeks = opts.weeks or {}
  }
end

-- Build timesheet structure with configurable parameters
function factory.build_timesheet(opts)
  opts = opts or {}

  return {
    date = opts.date or os.date("%Y-%m-%d"),
    intervals = opts.intervals or {},
    daily_total = opts.daily_total or "00:00"
  }
end

-- Build interval structure with configurable parameters
function factory.build_interval(opts)
  opts = opts or {}

  return {
    client = opts.client or "",
    project = opts.project or "",
    task = opts.task or "",
    start = opts.start or os.date("%I:%M %p"),
    stop = opts.stop or "",
    notes = opts.notes or {}
  }
end

return factory