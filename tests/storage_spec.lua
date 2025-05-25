-- storage_spec.lua
-- tests for the storage module

describe("storage", function()
  local storage = require('epoch.storage')
  local time_fixtures = require('tests.fixtures.time_fixtures')
  local interval_fixtures = require('tests.fixtures.interval_fixtures')
  local timesheet_fixtures = require('tests.fixtures.timesheet_fixtures')
  
  -- Set up a test data directory for isolation
  before_each(function()
    -- Override data directory to a test location
    storage.set_data_dir("/tmp/epoch_test_data")
    -- Ensure directory exists and is clean
    vim.fn.mkdir("/tmp/epoch_test_data", "p")
    vim.fn.system("rm -f /tmp/epoch_test_data/*.lua")
  end)
  
  -- Clean up after tests
  after_each(function()
    vim.fn.system("rm -rf /tmp/epoch_test_data")
  end)
  
  describe("get_data_dir", function()
    it("returns the configured data directory", function()
      assert.equals("/tmp/epoch_test_data", storage.get_data_dir())
    end)
  end)
  
  describe("get_today", function()
    it("returns today's date in YYYY-MM-DD format", function()
      local date = storage.get_today()
      assert.matches("%d%d%d%d%-%d%d%-%d%d", date)
    end)
  end)
  
  describe("get_timesheet_path", function()
    it("returns the correct path for a given date", function()
      local date = "2025-05-12"
      local expected_path = "/tmp/epoch_test_data/2025-05-12.lua"
      
      assert.equals(expected_path, storage.get_timesheet_path(date))
    end)
    
    it("uses today's date when no date is provided", function()
      local today = storage.get_today()
      local expected_path = "/tmp/epoch_test_data/" .. today .. ".lua"
      
      assert.equals(expected_path, storage.get_timesheet_path())
    end)
  end)
  
  describe("ensure_data_dir", function()
    it("creates the data directory if it doesn't exist", function()
      -- Remove directory for testing
      vim.fn.system("rm -rf /tmp/epoch_test_data")
      
      -- Call function and check if dir was created
      storage.ensure_data_dir()
      assert.equals(1, vim.fn.isdirectory("/tmp/epoch_test_data"))
    end)
  end)
  
  describe("create_default_timesheet", function()
    it("creates a timesheet with default values", function()
      local date = "2025-05-12"
      local timesheet = storage.create_default_timesheet(date)
      
      assert.equals(date, timesheet.date)
      assert.same({}, timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)
    
    it("uses today's date when no date is provided", function()
      local today = storage.get_today()
      local timesheet = storage.create_default_timesheet()
      
      assert.equals(today, timesheet.date)
    end)
  end)
  
  describe("serialize_timesheet", function()
    it("serializes timesheet to a valid Lua string", function()
      local timesheet = timesheet_fixtures.valid.with_intervals
      local lua_string = storage.serialize_timesheet(timesheet)
      
      -- Test if the resulting string is valid Lua
      local chunk, err = loadstring(lua_string)
      assert.is_nil(err)
      assert.is_function(chunk)
      
      -- Execute the chunk and check if it returns the expected table
      local result = chunk()
      assert.is_table(result)
      assert.equals(timesheet.date, result.date)
      assert.equals(#timesheet.intervals, #result.intervals)
    end)
    
    it("formats intervals with ordered keys", function()
      local timesheet = timesheet_fixtures.valid.with_intervals
      local lua_string = storage.serialize_timesheet(timesheet)
      
      -- Check for formatted keys in the serialized string
      assert.truthy(lua_string:match('client'))
      assert.truthy(lua_string:match('project'))
      assert.truthy(lua_string:match('task'))
      assert.truthy(lua_string:match('start'))
      assert.truthy(lua_string:match('stop'))
      assert.truthy(lua_string:match('notes'))
    end)
    
    it("properly serializes intervals with notes", function()
      -- Create a timesheet with an interval that has notes
      local timesheet = timesheet_fixtures.create("2025-05-12", {
        interval_fixtures.base.with_notes
      })
      
      -- Save and reload
      storage.save_timesheet(timesheet)
      local loaded = storage.load_timesheet(timesheet.date)
      
      -- Verify notes are preserved
      assert.is_table(loaded.intervals[1].notes)
      assert.equals(2, #loaded.intervals[1].notes)
      assert.equals("Added API documentation", loaded.intervals[1].notes[1])
      assert.equals("Reviewed with team", loaded.intervals[1].notes[2])
    end)
  end)
  
  describe("save_timesheet", function()
    it("saves timesheet to the correct file", function()
      local timesheet = timesheet_fixtures.valid.with_intervals
      local path = storage.get_timesheet_path(timesheet.date)
      
      storage.save_timesheet(timesheet)
      
      assert.equals(1, vim.fn.filereadable(path))
    end)
    
    it("creates directories if needed", function()
      -- Remove directory for testing
      vim.fn.system("rm -rf /tmp/epoch_test_data")
      
      local timesheet = timesheet_fixtures.valid.with_intervals
      local path = storage.get_timesheet_path(timesheet.date)
      
      storage.save_timesheet(timesheet)
      
      assert.equals(1, vim.fn.filereadable(path))
    end)
  end)
  
  describe("load_timesheet", function()
    it("loads timesheet from file", function()
      -- Save a timesheet first
      local original = timesheet_fixtures.valid.with_intervals
      storage.save_timesheet(original)
      
      -- Now load it
      local loaded = storage.load_timesheet(original.date)
      
      assert.equals(original.date, loaded.date)
      assert.equals(#original.intervals, #loaded.intervals)
      assert.equals(original.daily_total, loaded.daily_total)
    end)
    
    it("returns default timesheet if file doesn't exist", function()
      local date = "2099-01-01" -- A date in the future, unlikely to exist
      local timesheet = storage.load_timesheet(date)
      
      assert.equals(date, timesheet.date)
      assert.same({}, timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)
    
    it("uses today's date when no date is provided", function()
      local today = storage.get_today()
      local timesheet = storage.load_timesheet()
      
      assert.equals(today, timesheet.date)
    end)
    
    it("sorts intervals by start time", function()
      -- Create timesheet with out-of-order intervals
      local timesheet = {
        date = "2025-05-12",
        intervals = {
          interval_fixtures.base.backend,   -- Starts at 10:45 AM
          interval_fixtures.base.frontend,  -- Starts at 09:00 AM
        },
        daily_total = "03:00"
      }
      
      -- Save and reload it
      storage.save_timesheet(timesheet)
      local loaded = storage.load_timesheet(timesheet.date)
      
      -- Check if intervals are sorted
      assert.equals("09:00 AM", loaded.intervals[1].start)
      assert.equals("10:45 AM", loaded.intervals[2].start)
    end)
  end)
  
  describe("get_all_timesheet_files", function()
    it("returns empty array when no files exist", function()
      -- Clean directory
      vim.fn.system("rm -f /tmp/epoch_test_data/*.lua")
      
      local files = storage.get_all_timesheet_files()
      assert.same({}, files)
    end)
    
    it("returns all timesheet files in the data directory", function()
      -- Create some test files
      local dates = {"2025-05-10", "2025-05-11", "2025-05-12"}
      for _, date in ipairs(dates) do
        local timesheet = storage.create_default_timesheet(date)
        storage.save_timesheet(timesheet)
      end
      
      local files = storage.get_all_timesheet_files()
      assert.equals(#dates, #files)
    end)
  end)
  
  describe("delete_all_timesheets", function()
    it("deletes all timesheet files", function()
      -- Create some test files
      local dates = {"2025-05-10", "2025-05-11", "2025-05-12"}
      for _, date in ipairs(dates) do
        local timesheet = storage.create_default_timesheet(date)
        storage.save_timesheet(timesheet)
      end
      
      -- Verify files exist
      local before = storage.get_all_timesheet_files()
      assert.equals(#dates, #before)
      
      -- Delete files
      local count = storage.delete_all_timesheets()
      assert.equals(#dates, count)
      
      -- Verify files are gone
      local after = storage.get_all_timesheet_files()
      assert.same({}, after)
    end)
    
    it("returns 0 when no files exist", function()
      -- Clean directory
      vim.fn.system("rm -f /tmp/epoch_test_data/*.lua")
      
      local count = storage.delete_all_timesheets()
      assert.equals(0, count)
    end)
  end)
end)