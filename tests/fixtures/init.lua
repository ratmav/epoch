-- fixtures/init.lua
-- Central fixture registry that automatically returns deep copies

local fixtures = {}
local resolver = require('tests.fixtures.resolver')

-- Load all fixture modules
local interval_fixtures = require('tests.fixtures.epoch.interval_fixtures')
local timesheet_fixtures = require('tests.fixtures.epoch.timesheet_fixtures')
local time_fixtures = require('tests.fixtures.epoch.time_fixtures')
local ui_fixtures = require('tests.fixtures.epoch.ui_fixtures')
local report_fixtures = require('tests.fixtures.epoch.report_fixtures')
local laconic_fixtures = require('tests.fixtures.laconic')
local storage_fixtures = require('tests.fixtures.epoch.services.storage.serializer_fixtures')

-- Registry of all fixtures
local registry = {
  intervals = interval_fixtures,
  timesheets = timesheet_fixtures,
  time = time_fixtures,
  ui = ui_fixtures,
  reports = report_fixtures,
  laconic = laconic_fixtures,
  storage = storage_fixtures
}

-- Get a deep copy of any fixture
function fixtures.get(fixture_path)
  return resolver.get_fixture(registry, fixture_path)
end

return fixtures