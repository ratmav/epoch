-- tests/storage/discovery_spec.lua

local discovery = require('epoch.storage.discovery')
local paths = require('epoch.storage.paths')
local persistence = require('epoch.storage.persistence')

describe("storage discovery", function()
  -- Set up a test data directory for isolation
  before_each(function()
    paths.set_data_dir("/tmp/epoch_test_data")
    vim.fn.mkdir("/tmp/epoch_test_data", "p")
    vim.fn.system("rm -f /tmp/epoch_test_data/*.lua")
  end)
  
  -- Clean up after tests
  after_each(function()
    vim.fn.system("rm -rf /tmp/epoch_test_data")
  end)
  
  describe("get_all_timesheet_files", function()
    it("returns empty array when no files exist", function()
      vim.fn.system("rm -f /tmp/epoch_test_data/*.lua")
      
      local files = discovery.get_all_timesheet_files()
      assert.same({}, files)
    end)
    
    it("returns all timesheet files in the data directory", function()
      local dates = fixtures.get('time.dates.storage_test_dates')
      for _, date in ipairs(dates) do
        local timesheet = vim.deepcopy(fixtures.get('timesheets.valid.empty'))
        timesheet.date = date
        persistence.save_timesheet(timesheet)
      end
      
      local files = discovery.get_all_timesheet_files()
      assert.equals(#dates, #files)
    end)
    
    it("filters out non-timesheet lua files", function()
      -- Ensure clean directory first
      vim.fn.system("rm -rf /tmp/epoch_test_data")
      vim.fn.mkdir("/tmp/epoch_test_data", "p")
      
      -- Create a valid timesheet file
      local timesheet = vim.deepcopy(fixtures.get('timesheets.valid.empty'))
      timesheet.date = "2025-05-10"
      persistence.save_timesheet(timesheet)
      
      -- Create a non-timesheet lua file
      local non_timesheet_path = "/tmp/epoch_test_data/other_file.lua"
      local file = io.open(non_timesheet_path, 'w')
      file:write("return {}")
      file:close()
      
      local files = discovery.get_all_timesheet_files()
      assert.equals(1, #files)
      assert.truthy(files[1]:match("2025%-05%-10%.lua$"))
    end)
  end)
end)