-- fixtures/resolver.lua
-- Fixture path resolution and retrieval logic

local resolver = {}

-- Parse path like "timesheets.valid.with_intervals"
local function parse_fixture_path(fixture_path)
  return vim.split(fixture_path, ".", { plain = true })
end

-- Navigate registry using parsed path parts
local function navigate_registry(registry, path_parts)
  local current = registry
  for _, part in ipairs(path_parts) do
    current = current[part]
    if not current then
      return nil
    end
  end
  return current
end

-- Get a deep copy of any fixture by path
function resolver.get_fixture(registry, fixture_path)
  local path_parts = parse_fixture_path(fixture_path)
  local fixture = navigate_registry(registry, path_parts)

  if not fixture then
    error("Fixture not found: " .. fixture_path)
  end

  return vim.deepcopy(fixture)
end

return resolver
