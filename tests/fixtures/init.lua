-- fixtures/init.lua
-- Central fixture registry that automatically returns deep copies

local fixtures = {}
local resolver = require('tests.fixtures.resolver')

-- Load all fixture modules
local interval_fixtures = require('tests.fixtures.interval_fixtures')
local timesheet_fixtures = require('tests.fixtures.timesheet_fixtures')
local time_fixtures = require('tests.fixtures.time_fixtures')
local ui_fixtures = require('tests.fixtures.ui_fixtures')
local report_fixtures = require('tests.fixtures.report_fixtures')

-- Registry of all fixtures
local registry = {
  intervals = interval_fixtures,
  timesheets = timesheet_fixtures,
  time = time_fixtures,
  ui = ui_fixtures,
  reports = report_fixtures
}

-- Get a deep copy of any fixture
function fixtures.get(fixture_path)
  return resolver.get_fixture(registry, fixture_path)
end

return fixtures