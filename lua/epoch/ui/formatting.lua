-- epoch/ui/formatting.lua
-- Formatting utilities for UI display

local formatting = {}

-- Validate interval input for context generation
local function validate_interval_input(interval)
  return interval ~= nil
end

-- Collect non-nil interval fields into parts array
local function collect_interval_parts(interval)
  local parts = {}
  local fields = {"client", "project", "task", "start"}

  for _, field in ipairs(fields) do
    if interval[field] then
      table.insert(parts, interval[field])
    end
  end

  return parts
end

-- Format context parts into final string
local function format_context_parts(parts)
  if #parts == 0 then
    return "unknown interval"
  end
  return table.concat(parts, "/")
end

-- Get human-readable context for an interval
function formatting.get_interval_context(interval)
  if not validate_interval_input(interval) then
    return "unknown interval"
  end

  local parts = collect_interval_parts(interval)
  return format_context_parts(parts)
end

return formatting