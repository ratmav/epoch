-- report_helpers.lua
-- helper functions for report testing

local report_helpers = {}

-- Generate a report data structure from fixture data
-- This simulates what report.generate_report() would do but uses fixture data
function report_helpers.generate_report_from_fixtures(timesheets)
  -- Create a report structure similar to what report.generate_report() produces
  local report_data = {
    timesheets = timesheets,
    dates = {},
    summary = {},
    weeks = {},
    total_minutes = 0
  }
  
  -- Extract dates from timesheets
  for _, timesheet in ipairs(timesheets) do
    table.insert(report_data.dates, timesheet.date)
  end
  table.sort(report_data.dates)
  
  -- Add date range
  if #report_data.dates > 0 then
    report_data.date_range = {
      first = report_data.dates[1],
      last = report_data.dates[#report_data.dates]
    }
  end
  
  -- Calculate week numbers for each timesheet
  local timesheets_by_week = {}
  for _, timesheet in ipairs(timesheets) do
    local date_parts = vim.split(timesheet.date, "-")
    local year = tonumber(date_parts[1])
    local month = tonumber(date_parts[2])
    local day = tonumber(date_parts[3])
    
    local date = os.time({
      year = year,
      month = month,
      day = day
    })
    
    local week = os.date("%Y-%U", date)
    
    if not timesheets_by_week[week] then
      timesheets_by_week[week] = {
        week = week,
        dates = {},
        timesheets = {},
        summary = {},
        total_minutes = 0,
        daily_totals = {},
        date_range = {
          first = os.date("%Y-%m-%d", date - (tonumber(os.date("%w", date)) * 86400)),
          last = os.date("%Y-%m-%d", date + ((6 - tonumber(os.date("%w", date))) * 86400))
        }
      }
    end
    
    table.insert(timesheets_by_week[week].dates, timesheet.date)
    table.insert(timesheets_by_week[week].timesheets, timesheet)
  end
  
  -- Convert weeks to array and sort
  for _, week_data in pairs(timesheets_by_week) do
    table.insert(report_data.weeks, week_data)
  end
  
  -- Sort weeks with most recent first
  table.sort(report_data.weeks, function(a, b)
    return a.week > b.week
  end)
  
  -- Calculate total minutes and summaries
  local all_summary = {}
  local total_minutes = 0
  
  for _, timesheet in ipairs(timesheets) do
    local day_total = 0
    
    for _, interval in ipairs(timesheet.intervals) do
      if interval.client and interval.project and interval.task and interval.start and interval.stop then
        -- Calculate interval minutes (simplified approximation)
        local minutes = 0
        
        -- Extract hours and minutes from start and stop times
        local start_hour, start_min = interval.start:match("(%d+):(%d+)")
        local stop_hour, stop_min = interval.stop:match("(%d+):(%d+)")
        
        if start_hour and start_min and stop_hour and stop_min then
          start_hour = tonumber(start_hour)
          start_min = tonumber(start_min)
          stop_hour = tonumber(stop_hour)
          stop_min = tonumber(stop_min)
          
          -- Adjust for AM/PM
          if interval.start:match("PM") and start_hour < 12 then
            start_hour = start_hour + 12
          elseif interval.start:match("AM") and start_hour == 12 then
            start_hour = 0
          end
          
          if interval.stop:match("PM") and stop_hour < 12 then
            stop_hour = stop_hour + 12
          elseif interval.stop:match("AM") and stop_hour == 12 then
            stop_hour = 0
          end
          
          -- Calculate minutes
          local start_minutes = start_hour * 60 + start_min
          local stop_minutes = stop_hour * 60 + stop_min
          
          minutes = stop_minutes - start_minutes
          if minutes < 0 then 
            minutes = minutes + (24 * 60) -- Handle crossing midnight
          end
          
          -- Add to totals
          day_total = day_total + minutes
          total_minutes = total_minutes + minutes
          
          -- Update summaries
          local key = interval.client .. "|" .. interval.project .. "|" .. interval.task
          if not all_summary[key] then
            all_summary[key] = {
              client = interval.client,
              project = interval.project,
              task = interval.task,
              minutes = 0
            }
          end
          
          all_summary[key].minutes = all_summary[key].minutes + minutes
          
          -- Add to week summary
          local week = nil
          for _, w in ipairs(report_data.weeks) do
            if vim.tbl_contains(w.dates, timesheet.date) then
              week = w
              break
            end
          end
          
          if week then
            local week_key = interval.client .. "|" .. interval.project .. "|" .. interval.task
            if not week.summary[week_key] then
              week.summary[week_key] = {
                client = interval.client,
                project = interval.project,
                task = interval.task,
                minutes = 0
              }
            end
            
            week.summary[week_key].minutes = week.summary[week_key].minutes + minutes
            week.total_minutes = week.total_minutes + minutes
            
            -- Add daily total
            week.daily_totals[timesheet.date] = (week.daily_totals[timesheet.date] or 0) + minutes
          end
        end
      end
    end
  end
  
  -- Convert summary to array
  for _, entry in pairs(all_summary) do
    table.insert(report_data.summary, entry)
  end
  
  -- Sort summary
  table.sort(report_data.summary, function(a, b)
    if a.client ~= b.client then
      return a.client < b.client
    elseif a.project ~= b.project then
      return a.project < b.project
    else
      return a.task < b.task
    end
  end)
  
  -- Convert week summaries to arrays
  for _, week in ipairs(report_data.weeks) do
    local summary_array = {}
    for _, entry in pairs(week.summary) do
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
    
    week.summary = summary_array
  end
  
  report_data.total_minutes = total_minutes
  
  return report_data
end

return report_helpers