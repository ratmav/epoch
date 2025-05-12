-- epoch/time_utils/formatting.lua
-- Time formatting utilities

local formatting = {}

-- format minutes as HH:MM
function formatting.format_duration(minutes)
  if not minutes or minutes < 0 then
    minutes = 0
  end

  local hours = math.floor(minutes / 60)
  local mins = math.floor(minutes % 60)
  return string.format("%02d:%02d", hours, mins)
end

-- format timestamp as h:MM AM/PM
function formatting.format_time(timestamp)
  return os.date('%I:%M %p', timestamp)
end

return formatting