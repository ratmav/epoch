-- interval_helpers.lua
-- helper functions for working with intervals in tests

local interval_helpers = {}

-- Helper function to create a modified copy of an interval
function interval_helpers.derive_interval(base, changes)
  local result = {}
  -- Copy the base fields
  for k, v in pairs(base) do
    result[k] = v
  end
  -- Apply changes, including explicit nil values
  if changes then
    for k, v in pairs(changes) do
      result[k] = v
    end
  end
  return result
end

return interval_helpers