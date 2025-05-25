-- epoch/storage.lua
-- Main storage interface - delegates to specialized modules

local storage = {}
local paths = require('epoch.storage.paths')
local file_ops = require('epoch.storage.file_ops')
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
  date = date or paths.get_today()
  return {
    date = date,
    intervals = {},
    daily_total = "00:00"
  }
end

-- File operations
function storage.serialize_timesheet(timesheet)
  return serializer.serialize_timesheet(timesheet)
end

function storage.save_timesheet(timesheet)
  return file_ops.save_timesheet(timesheet)
end

function storage.load_timesheet(date)
  return file_ops.load_timesheet(date)
end

function storage.get_all_timesheet_files()
  return file_ops.get_all_timesheet_files()
end

function storage.delete_all_timesheets()
  return file_ops.delete_all_timesheets()
end

return storage