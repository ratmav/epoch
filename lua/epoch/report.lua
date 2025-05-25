-- epoch/report.lua
-- reporting functionality for epoch time tracking

local report = {}
local storage = require('epoch.storage')
local time_utils = require('epoch.time_utils')
local validation = require('epoch.validation')

-- Load all available timesheets
function report.get_all_timesheet_dates()
  local files = storage.get_all_timesheet_files()
  local dates = {}
  
  for _, file_path in ipairs(files) do
    -- Extract date from filename (YYYY-MM-DD.lua)
    local date = vim.fn.fnamemodify(file_path, ":t:r")
    if date:match("^%d%d%d%d%-%d%d%-%d%d$") then
      table.insert(dates, date)
    end
  end
  
  -- Sort dates chronologically
  table.sort(dates)
  
  return dates
end

-- Calculate minutes between two time strings on the same day
local function calculate_interval_minutes(interval, date)
  -- Skip unclosed intervals
  if not interval.stop or interval.stop == "" then
    return 0
  end
  
  local start_time = time_utils.time_to_seconds(interval.start, date)
  local stop_time = time_utils.time_to_seconds(interval.stop, date)
  
  if not start_time or not stop_time then
    return 0
  end
  
  -- Calculate minutes
  local diff_seconds = stop_time - start_time
  return math.max(0, math.floor(diff_seconds / 60))
end

-- Get week number from date string (YYYY-MM-DD)
local function get_week_number(date_str)
  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")
  if not year or not month or not day then
    return nil
  end
  
  local date = os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day)
  })
  
  -- Calculate week number (Sunday is first day of week)
  return os.date("%Y-%U", date)
end

-- Get week date range from week number string (YYYY-WW)
local function get_week_date_range(week_str)
  local year, week = week_str:match("(%d+)-(%d+)")
  if not year or not week then
    return nil
  end
  
  -- Create a timestamp for the first day of the year
  local year_start = os.time({
    year = tonumber(year),
    month = 1,
    day = 1,
    hour = 0,
    min = 0,
    sec = 0
  })
  
  -- Get the weekday of January 1st (0 = Sunday, 1 = Monday, etc.)
  local jan1_wday = tonumber(os.date("%w", year_start))
  
  -- Calculate the timestamp for the first day of the given week
  local week_start = year_start + (tonumber(week) * 7 * 86400)
  
  -- Adjust for the weekday of January 1st
  if jan1_wday > 0 then
    week_start = week_start - (jan1_wday * 86400)
  end
  
  -- Calculate the end of the week (Saturday)
  local week_end = week_start + (6 * 86400)
  
  return {
    first = os.date("%Y-%m-%d", week_start),
    last = os.date("%Y-%m-%d", week_end)
  }
end

-- Generate a report for all timesheets
function report.generate_report()
  local all_dates = report.get_all_timesheet_dates()
  local timesheets = {}
  local timesheets_by_week = {}
  
  -- Load all available timesheets
  for _, date in ipairs(all_dates) do
    local timesheet = storage.load_timesheet(date)
    if timesheet and timesheet.intervals and #timesheet.intervals > 0 then
      -- Add to flat list
      table.insert(timesheets, timesheet)
      
      -- Group by week
      local week = get_week_number(date)
      if week then
        if not timesheets_by_week[week] then
          timesheets_by_week[week] = {
            dates = {},
            timesheets = {},
            summary = {},
            total_minutes = 0,
            date_range = get_week_date_range(week)
          }
        end
        
        table.insert(timesheets_by_week[week].dates, date)
        table.insert(timesheets_by_week[week].timesheets, timesheet)
      end
    end
  end
  
  -- If no timesheets found
  if #timesheets == 0 then
    return {
      timesheets = {},
      summary = {},
      total_minutes = 0,
      dates = all_dates,
      date_range = #all_dates > 0 and {first = all_dates[1], last = all_dates[#all_dates]} or nil,
      weeks = {}
    }
  end
  
  -- Process each week
  local weeks = {}
  local all_summary = {}
  local total_minutes = 0
  
  for week, week_data in pairs(timesheets_by_week) do
    local week_summary = {}
    local week_total_minutes = 0
    local daily_totals = {}
    
    -- Process each timesheet in this week
    for _, timesheet in ipairs(week_data.timesheets) do
      local day_total = 0
      
      -- Sort the timesheet dates in chronological order
      table.sort(week_data.dates)
      
      -- Create entry for each day of the week
      for _, interval in ipairs(timesheet.intervals) do
        -- Skip incomplete intervals
        if interval.client and interval.project and interval.task and interval.start then
          local minutes = calculate_interval_minutes(interval, timesheet.date)
          
          -- Update day total
          day_total = day_total + minutes
          
          -- Update week summary
          local key = interval.client .. "|" .. interval.project .. "|" .. interval.task
          if not week_summary[key] then
            week_summary[key] = {
              client = interval.client,
              project = interval.project,
              task = interval.task,
              minutes = 0
            }
          end
          
          week_summary[key].minutes = week_summary[key].minutes + minutes
          week_total_minutes = week_total_minutes + minutes
          
          -- Also update overall summary
          if not all_summary[key] then
            all_summary[key] = {
              client = interval.client,
              project = interval.project,
              task = interval.task,
              minutes = 0
            }
          end
          
          all_summary[key].minutes = all_summary[key].minutes + minutes
          total_minutes = total_minutes + minutes
        end
      end
      
      -- Add the daily total
      daily_totals[timesheet.date] = day_total
    end
    
    -- Convert week summary to array and sort
    local week_summary_array = {}
    for _, entry in pairs(week_summary) do
      table.insert(week_summary_array, entry)
    end
    
    table.sort(week_summary_array, function(a, b)
      if a.client ~= b.client then
        return a.client < b.client
      elseif a.project ~= b.project then
        return a.project < b.project
      else
        return a.task < b.task
      end
    end)
    
    -- Add week data to result
    week_data.summary = week_summary_array
    week_data.total_minutes = week_total_minutes
    week_data.daily_totals = daily_totals
    
    table.insert(weeks, {
      week = week,
      dates = week_data.dates,
      summary = week_summary_array,
      total_minutes = week_total_minutes,
      date_range = week_data.date_range,
      daily_totals = daily_totals
    })
  end
  
  -- Sort weeks chronologically, most recent first (latest/current week at the top)
  table.sort(weeks, function(a, b)
    return a.week > b.week
  end)
  
  -- Convert all_summary to array and sort by client/project/task
  local summary_array = {}
  for _, entry in pairs(all_summary) do
    table.insert(summary_array, entry)
  end
  
  table.sort(summary_array, function(a, b)
    if a.client ~= b.client then
      return a.client < b.client
    elseif a.project ~= b.project then
      return a.project < b.project
    else
      return a.task < b.task
    end
  end)
  
  return {
    timesheets = timesheets,
    summary = summary_array,
    total_minutes = total_minutes,
    dates = all_dates,
    date_range = #all_dates > 0 and {first = all_dates[1], last = all_dates[#all_dates]} or nil,
    weeks = weeks
  }
end

-- Format the report as a string for display
function report.format_report(report_data)
  local lines = {}
  
  -- Helper function to format a summary table
  local function format_summary_table(summary, total_mins)
    local result = {}
    
    if #summary == 0 then
      table.insert(result, "No time entries found for this period.")
      table.insert(result, "")
      return result
    end
    
    -- Calculate padding for formatting
    local max_client_len = 6  -- "Client"
    local max_project_len = 7 -- "Project"
    local max_task_len = 4    -- "Task"
    
    for _, entry in ipairs(summary) do
      max_client_len = math.max(max_client_len, #entry.client)
      max_project_len = math.max(max_project_len, #entry.project)
      max_task_len = math.max(max_task_len, #entry.task)
    end
    
    -- Add header row
    local header = string.format("%-" .. max_client_len .. "s  %-" .. max_project_len .. "s  %-" .. max_task_len .. "s  %s",
      "Client", "Project", "Task", "Hours")
    table.insert(result, header)
    
    local separator = string.rep("-", max_client_len) .. "  " ..
                      string.rep("-", max_project_len) .. "  " ..
                      string.rep("-", max_task_len) .. "  ------"
    table.insert(result, separator)
    
    -- Add data rows
    for _, entry in ipairs(summary) do
      local formatted_time = time_utils.format_duration(entry.minutes)
      local row = string.format("%-" .. max_client_len .. "s  %-" .. max_project_len .. "s  %-" .. max_task_len .. "s  %s",
        entry.client, entry.project, entry.task, formatted_time)
      table.insert(result, row)
    end
    
    -- Add total
    table.insert(result, separator)
    local total_row = string.format("%-" .. max_client_len .. "s  %-" .. (max_project_len + max_task_len + 2) .. "s  %s",
      "TOTAL", "", time_utils.format_duration(total_mins))
    table.insert(result, total_row)
    
    return result
  end
  
  -- Add date range if available
  if report_data.date_range then
    table.insert(lines, string.format("Period: %s to %s", report_data.date_range.first, report_data.date_range.last))
    table.insert(lines, "")
  end
  
  -- We'll add overall summaries at the end, not the start
  
  -- Helper function to format a summary table
  local function format_summary_table(summary, total_mins)
    local result = {}
    
    if #summary == 0 then
      table.insert(result, "No time entries found for this period.")
      table.insert(result, "")
      return result
    end
    
    -- Calculate padding for formatting
    local max_client_len = 6  -- "Client"
    local max_project_len = 7 -- "Project"
    local max_task_len = 4    -- "Task"
    
    for _, entry in ipairs(summary) do
      max_client_len = math.max(max_client_len, #entry.client)
      max_project_len = math.max(max_project_len, #entry.project)
      max_task_len = math.max(max_task_len, #entry.task)
    end
    
    -- Add header row
    local header = string.format("%-" .. max_client_len .. "s  %-" .. max_project_len .. "s  %-" .. max_task_len .. "s  %s",
      "Client", "Project", "Task", "Hours")
    table.insert(result, header)
    
    local separator = string.rep("-", max_client_len) .. "  " ..
                      string.rep("-", max_project_len) .. "  " ..
                      string.rep("-", max_task_len) .. "  ------"
    table.insert(result, separator)
    
    -- Add data rows
    for _, entry in ipairs(summary) do
      local formatted_time = time_utils.format_duration(entry.minutes)
      local row = string.format("%-" .. max_client_len .. "s  %-" .. max_project_len .. "s  %-" .. max_task_len .. "s  %s",
        entry.client, entry.project, entry.task, formatted_time)
      table.insert(result, row)
    end
    
    -- Add total
    table.insert(result, separator)
    local total_row = string.format("%-" .. max_client_len .. "s  %-" .. (max_project_len + max_task_len + 2) .. "s  %s",
      "TOTAL", "", time_utils.format_duration(total_mins))
    table.insert(result, total_row)
    
    return result
  end
  
  -- If no weeks available, just show overall summary
  if not report_data.weeks or #report_data.weeks == 0 then
    table.insert(lines, "## Overall By Client")
    table.insert(lines, "")
    
    for _, line in ipairs(format_summary_table(report_data.summary, report_data.total_minutes)) do
      table.insert(lines, line)
    end
    
    return table.concat(lines, "\n")
  end
  
  -- Show each week's summary
  for _, week in ipairs(report_data.weeks) do
    if week.date_range then
      table.insert(lines, string.format("## Week of %s to %s", week.date_range.first, week.date_range.last))
    else
      table.insert(lines, string.format("## Week %s", week.week))
    end
    table.insert(lines, "")
    
    -- Add daily breakdown
    if week.daily_totals and week.dates and #week.dates > 0 then
      table.insert(lines, "### By Day")
      table.insert(lines, "")
      
      -- Sort dates chronologically
      local sorted_dates = {}
      for date, _ in pairs(week.daily_totals) do
        table.insert(sorted_dates, date)
      end
      table.sort(sorted_dates)
      
      -- Create a table for daily totals
      table.insert(lines, "Date         Hours")
      table.insert(lines, "------------ ------")
      
      for _, date in ipairs(sorted_dates) do
        local minutes = week.daily_totals[date] or 0
        local formatted_time = time_utils.format_duration(minutes)
        table.insert(lines, string.format("%-12s %s", date, formatted_time))
      end
      
      -- Add week total
      table.insert(lines, "------------ ------")
      table.insert(lines, string.format("%-12s %s", "TOTAL", time_utils.format_duration(week.total_minutes)))
      
      table.insert(lines, "")
    end
    
    -- Add summary by client/project/task
    table.insert(lines, "### By Client")
    table.insert(lines, "")
    
    for _, line in ipairs(format_summary_table(week.summary, week.total_minutes)) do
      table.insert(lines, line)
    end
    
    table.insert(lines, "")
    table.insert(lines, "")
  end
  
  -- Add overall summaries at the end if we have weeks
  if report_data.weeks and #report_data.weeks > 0 then
    -- Overall summary by week
    table.insert(lines, "## Overall By Week")
    table.insert(lines, "")
    
    -- Calculate max width needed for week labels
    local max_week_label_len = 4  -- "Week"
    for _, week in ipairs(report_data.weeks) do
      local week_num = week.week:match("^%d+%-(%d+)$") or ""
      max_week_label_len = math.max(max_week_label_len, #(week.date_range.first or ""))
    end
    
    -- Ensure min width of 19 for "YYYY-MM-DD to YYYY-MM-DD" format
    max_week_label_len = math.max(max_week_label_len + 4, 19)  -- +4 for "Week " prefix
    
    -- Create a table for weekly totals
    local header = string.format("%-" .. max_week_label_len .. "s  %s", "Week", "Hours")
    table.insert(lines, header)
    
    local separator = string.rep("-", max_week_label_len) .. "  ------"
    table.insert(lines, separator)
    
    local total_all_weeks = 0
    
    -- The weeks are already sorted (latest first) in generate_report()
    for _, week in ipairs(report_data.weeks) do
      local week_label
      if week.date_range then
        week_label = string.format("Week %s", week.date_range.first)
      else
        week_label = string.format("Week %s", week.week)
      end
      
      local formatted_time = time_utils.format_duration(week.total_minutes)
      table.insert(lines, string.format("%-" .. max_week_label_len .. "s  %s", week_label, formatted_time))
      
      total_all_weeks = total_all_weeks + week.total_minutes
    end
    
    -- Add total across all weeks
    table.insert(lines, separator)
    table.insert(lines, string.format("%-" .. max_week_label_len .. "s  %s", "TOTAL", time_utils.format_duration(total_all_weeks)))
    
    table.insert(lines, "")
    table.insert(lines, "")
    
    -- Overall summary by client
    table.insert(lines, "## Overall By Client")
    table.insert(lines, "")
    
    for _, line in ipairs(format_summary_table(report_data.summary, report_data.total_minutes)) do
      table.insert(lines, line)
    end
  end
  
  return table.concat(lines, "\n")
end

-- Track window and buffer state
local report_buffer = nil
local report_window = nil

-- Check if report window is open
local function is_window_open()
  return report_window ~= nil and vim.api.nvim_win_is_valid(report_window)
end

-- Close report window
local function close_window()
  -- If window is open, close it
  if is_window_open() then
    vim.api.nvim_win_close(report_window, true)
    report_window = nil
  end
  
  -- Clean up buffer
  if report_buffer ~= nil and vim.api.nvim_buf_is_valid(report_buffer) then
    vim.api.nvim_buf_delete(report_buffer, { force = true })
    report_buffer = nil
  end
end

-- Open report window
local function open_window()
  -- Generate report data
  local report_data = report.generate_report()
  local content = report.format_report(report_data)
  
  -- Create a new buffer for the report
  report_buffer = vim.api.nvim_create_buf(false, true)
  
  -- Set initial buffer options
  vim.api.nvim_buf_set_option(report_buffer, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(report_buffer, 'filetype', 'markdown')
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(report_buffer, 0, -1, false, vim.split(content, '\n'))
  
  -- Set buffer as read-only after content is set
  vim.api.nvim_buf_set_option(report_buffer, 'modifiable', false)
  vim.api.nvim_buf_set_option(report_buffer, 'readonly', true)
  
  -- Calculate window dimensions (50% width, 60% height)
  local width = math.floor(vim.o.columns * 0.5)
  local height = math.floor(vim.o.lines * 0.6)
  
  -- Create floating window
  report_window = vim.api.nvim_open_win(report_buffer, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = 'Epoch Report',
    title_pos = 'center',
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(report_window, 'wrap', false)
  vim.api.nvim_win_set_option(report_window, 'cursorline', true)
  vim.api.nvim_win_set_option(report_window, 'winhl', 'Normal:EpochNormal,FloatBorder:EpochBorder')
  
  -- Set window-local keymaps
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(report_buffer, 'n', 'q', ':lua require("epoch.report").toggle_report()<CR>', opts)
  vim.api.nvim_buf_set_keymap(report_buffer, 'n', '<Esc>', ':lua require("epoch.report").toggle_report()<CR>', opts)
end

-- Toggle report window
function report.toggle_report()
  if is_window_open() then
    close_window()
  else
    open_window()
  end
end

return report