-- epoch/timeops.lua
-- time operations for epoch time tracking

local timeops = {}
local storage = require('epoch.storage')

-- Convert time string to timestamp
local function time_to_seconds(time_str, date_str)
  local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
  if not hour or not min or not period then
    return nil
  end

  -- Convert to 24 hour format
  hour = tonumber(hour)
  min = tonumber(min)

  if period == "PM" and hour < 12 then
    hour = hour + 12
  elseif period == "AM" and hour == 12 then
    hour = 0
  end

  -- Get date components
  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")

  -- Create timestamp
  return os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = hour,
    min = min
  })
end

-- format time as h:MM AM/PM
local function format_time(timestamp)
  return os.date('%I:%M %p', timestamp)
end

-- format minutes as HH:MM
function timeops.format_duration(minutes)
  local hours = math.floor(minutes / 60)
  local mins = math.floor(minutes % 60)
  return string.format("%02d:%02d", hours, mins)
end

-- calculate the elapsed time between two timestamps in minutes
local function calculate_elapsed(start_timestamp, end_timestamp)
  return os.difftime(end_timestamp, start_timestamp) / 60 -- minutes
end

-- add start time to the current timesheet
function timeops.start_interval(client, project, task)
  local timesheet = storage.load_timesheet()

  -- Use the standard interval template
  local interval = storage.create_interval(client, project, task)

  table.insert(timesheet.intervals, interval)
  storage.save_timesheet(timesheet)

  return timesheet
end

-- end the latest interval in the timesheet
function timeops.end_interval()
  local timesheet = storage.load_timesheet()

  if #timesheet.intervals == 0 then
    vim.notify("epoch: no active interval to end", vim.log.levels.ERROR)
    return timesheet
  end

  local interval = timesheet.intervals[#timesheet.intervals]

  if interval["end"] and interval["end"] ~= "" then
    vim.notify("epoch: last interval already ended", vim.log.levels.ERROR)
    return timesheet
  end

  -- Set the end time using the current time
  local end_time = os.time()
  interval["end"] = os.date('%I:%M %p', end_time)

  -- Calculate total minutes for the day
  local total_minutes = 0
  for _, intvl in ipairs(timesheet.intervals) do
    if intvl["end"] and intvl["end"] ~= "" then
      local start_secs = time_to_seconds(intvl.start, timesheet.date)
      local end_secs = time_to_seconds(intvl["end"], timesheet.date)

      if start_secs and end_secs then
        total_minutes = total_minutes + math.floor((end_secs - start_secs) / 60)
      end
    end
  end

  -- Format daily total as HH:MM
  timesheet.daily_total = timeops.format_duration(total_minutes)

  storage.save_timesheet(timesheet)
  return timesheet
end

-- Convert time string to timestamp
local function time_to_seconds(time_str, date_str)
  local hour, min, period = time_str:match("(%d+):(%d+)%s+([AP]M)")
  if not hour or not min or not period then
    return nil
  end

  -- Convert to 24 hour format
  hour = tonumber(hour)
  min = tonumber(min)

  if period == "PM" and hour < 12 then
    hour = hour + 12
  elseif period == "AM" and hour == 12 then
    hour = 0
  end

  -- Get date components
  local year, month, day = date_str:match("(%d+)-(%d+)-(%d+)")

  -- Create timestamp
  return os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = hour,
    min = min
  })
end

-- add a new complete interval with auto-timing
function timeops.add_interval()
  -- prompt for client and project
  vim.ui.input({ prompt = "client: " }, function(client)
    if not client or client == "" then return end

    vim.ui.input({ prompt = "project: " }, function(project)
      if not project or project == "" then return end

      vim.ui.input({ prompt = "task: " }, function(task)
        if not task or task == "" then return end

        -- use current time
        local current_time = os.time()
        local current_formatted = os.date('%I:%M %p', current_time)

        -- create timesheet if needed
        local timesheet = storage.load_timesheet()

        -- Check if there's an existing interval that needs to be closed
        if #timesheet.intervals > 0 then
          local last_interval = timesheet.intervals[#timesheet.intervals]

          -- If the last interval has no end time, close it
          if not last_interval["end"] or last_interval["end"] == "" then
            -- Make sure all required fields exist
            if not storage.validate_interval(last_interval) then
              -- Remove invalid interval
              vim.notify("epoch: removing invalid interval from timesheet", vim.log.levels.WARN)
              table.remove(timesheet.intervals)
            else
              -- Get the timestamp for the last interval's start time
              local last_start_time = time_to_seconds(last_interval.start, timesheet.date)

              if last_start_time then
                local end_time
                local end_formatted

                -- Calculate time since last interval started
                local elapsed = current_time - last_start_time

                -- If it's been less than a minute, end the interval at start + 1 minute
                if elapsed < 60 then
                  end_time = last_start_time + 60
                  end_formatted = os.date('%I:%M %p', end_time)

                  -- And start the new interval 1 minute after that
                  current_time = end_time + 60
                  current_formatted = os.date('%I:%M %p', current_time)
                else
                  -- Normal case: end at current time
                  end_time = current_time
                  end_formatted = current_formatted

                  -- Start new interval 1 minute after that
                  current_time = end_time + 60
                  current_formatted = os.date('%I:%M %p', current_time)
                end

                last_interval["end"] = end_formatted

                -- Notify about closing the previous interval
                vim.notify("epoch: closed previous interval at " .. end_formatted, vim.log.levels.INFO)
              end
            end
          end
        end

        -- Create a new interval with the adjusted current time
        local interval = storage.create_interval(client, project, task, current_time)

        table.insert(timesheet.intervals, interval)

        -- Calculate total minutes for the day
        local total_minutes = 0
        for _, intvl in ipairs(timesheet.intervals) do
          if intvl["end"] and intvl["end"] ~= "" then
            local start_secs = time_to_seconds(intvl.start, timesheet.date)
            local end_secs = time_to_seconds(intvl["end"], timesheet.date)

            if start_secs and end_secs then
              total_minutes = total_minutes + math.floor((end_secs - start_secs) / 60)
            end
          end
        end

        -- Format daily total as HH:MM
        timesheet.daily_total = timeops.format_duration(total_minutes)

        storage.save_timesheet(timesheet)

        -- Clear screen and show clean notification
        vim.cmd("redraw!")  -- Clear the screen
        vim.notify("epoch: time tracking started for " .. client .. "/" .. project .. "/" .. task, vim.log.levels.INFO)
      end)
    end)
  end)
end

-- get timesheets for a date range
function timeops.get_timesheets(start_date, end_date)
  local results = {}
  local current_date = start_date
  
  while current_date <= end_date do
    local timesheet = storage.load_timesheet(current_date)
    results[current_date] = timesheet
    
    -- move to next day (this is a simplistic approach)
    local y, m, d = current_date:match("(%d+)-(%d+)-(%d+)")
    local timestamp = os.time({year = y, month = m, day = d})
    timestamp = timestamp + 86400 -- add one day
    current_date = os.date("%Y-%m-%d", timestamp)
  end
  
  return results
end

-- get weekly report for the current week
function timeops.get_weekly_report()
  -- calculate the dates for the current week (Monday-Sunday)
  local now = os.time()
  local day_of_week = tonumber(os.date("%w", now)) -- 0 is Sunday
  if day_of_week == 0 then day_of_week = 7 end -- convert to 1-7 (Mon-Sun)

  local monday = now - ((day_of_week - 1) * 86400)
  local sunday = monday + (6 * 86400)

  local start_date = os.date("%Y-%m-%d", monday)
  local end_date = os.date("%Y-%m-%d", sunday)

  -- get all timesheets for the week
  local timesheets = timeops.get_timesheets(start_date, end_date)

  -- calculate totals by client/project
  local totals = {}
  local grand_total_minutes = 0

  for date, timesheet in pairs(timesheets) do
    for _, interval in ipairs(timesheet.intervals or {}) do
      -- Only count completed intervals (with both start and end times)
      if interval.start and interval["end"] and interval["end"] ~= "" then
        local client = interval.client or "unnamed"
        local project = interval.project or "unnamed"
        local task = interval.task or "unnamed"

        -- Calculate duration from formatted times
        local start_secs = time_to_seconds(interval.start, date)
        local end_secs = time_to_seconds(interval["end"], date)

        if start_secs and end_secs then
          local duration_mins = math.floor((end_secs - start_secs) / 60)

          if not totals[client] then totals[client] = {} end
          if not totals[client][project] then totals[client][project] = {} end
          if not totals[client][project][task] then totals[client][project][task] = 0 end

          totals[client][project][task] = totals[client][project][task] + duration_mins
          grand_total_minutes = grand_total_minutes + duration_mins
        end
      end
    end
  end

  return {
    start_date = start_date,
    end_date = end_date,
    timesheets = timesheets,
    totals = totals,
    grand_total = timeops.format_duration(grand_total_minutes),
    grand_total_minutes = grand_total_minutes
  }
end

-- clear all timesheet files
function timeops.clear_timesheets()
  -- print confirmation prompt in warning color
  vim.api.nvim_echo({{"are you sure? [y/N]: ", "WarningMsg"}}, false, {})
  
  -- get user input
  local input = vim.fn.nr2char(vim.fn.getchar())
  
  -- add newline after input
  print("")
  
  -- process response
  if input:lower() == "y" then
    local count = storage.delete_all_timesheets()
    if count > 0 then
      vim.notify("epoch: " .. count .. " timesheet files deleted", vim.log.levels.INFO)
    else
      vim.notify("epoch: no timesheet files found", vim.log.levels.INFO)
    end
  end
end

return timeops