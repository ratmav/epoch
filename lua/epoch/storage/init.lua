-- epoch/storage.lua
-- Main storage interface - delegates to specialized modules
-- coverage: no tests

local storage = {}
local paths = require('epoch.storage.paths')
local persistence = require('epoch.storage.persistence')
local discovery = require('epoch.storage.discovery')
local bulk_operations = require('epoch.storage.bulk_operations')
local serializer = require('epoch.storage.serializer')

-- Path management functions
function storage.set_data_dir(path)
  paths.set_data_dir(path)
end

function storage._set_data_dir_for_tests(path)
  paths.set_data_dir(path)
end

function storage.get_data_dir()
  return paths.get_data_dir()
end

function storage.get_today()
  return paths.get_today()
end

function storage.get_timesheet_path(date)
  return paths.get_timesheet_path(date)
end

function storage.ensure_data_dir()
  paths.ensure_data_dir()
end

-- Data creation functions
function storage.create_default_timesheet(date)
  return persistence.create_default_timesheet(date)
end

-- File operations
function storage.serialize_timesheet(timesheet)
  return serializer.serialize_timesheet(timesheet)
end

function storage.save_timesheet(timesheet)
  return persistence.save_timesheet(timesheet)
end

function storage.load_timesheet(date)
  return persistence.load_timesheet(date)
end

function storage.deserialize_content(content)
  return persistence.deserialize_content(content)
end

function storage.load_timesheet_content(timesheet_path)
  return persistence.load_timesheet_content(timesheet_path)
end

function storage.get_all_timesheet_files()
  return discovery.get_all_timesheet_files()
end

function storage.delete_all_timesheets()
  return bulk_operations.delete_all_timesheets()
end

return storage