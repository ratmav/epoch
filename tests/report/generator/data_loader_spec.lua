-- tests/report/generator/data_loader_spec.lua

local data_loader = require('epoch.report.generator.data_loader')
local storage = require('epoch.storage')

describe("report generator data_loader", function()
  -- Set up a test data directory for isolation
  before_each(function()
    storage.set_data_dir("/tmp/epoch_test_data")
    vim.fn.mkdir("/tmp/epoch_test_data", "p")
    vim.fn.system("rm -f /tmp/epoch_test_data/*.lua")
  end)
  
  -- Clean up after tests
  after_each(function()
    vim.fn.system("rm -rf /tmp/epoch_test_data")
  end)
  
  describe("get_all_timesheet_dates", function()
    it("returns empty array when no files exist", function()
      vim.fn.system("rm -f /tmp/epoch_test_data/*.lua")
      
      local dates = data_loader.get_all_timesheet_dates()
      assert.same({}, dates)
    end)
    
    it("extracts dates from timesheet files", function()
      -- Create test timesheet files
      local dates = {"2025-01-01", "2025-01-03", "2025-01-02"}
      for _, date in ipairs(dates) do
        local timesheet = {
          date = date,
          intervals = {},
          daily_total = "00:00"
        }
        storage.save_timesheet(timesheet)
      end
      
      local result = data_loader.get_all_timesheet_dates()
      
      assert.equals(3, #result)
      assert.equals("2025-01-01", result[1])
      assert.equals("2025-01-02", result[2])
      assert.equals("2025-01-03", result[3])
    end)
    
    it("filters out invalid date formats", function()
      -- Create a valid timesheet
      storage.save_timesheet({date = "2025-01-01", intervals = {}, daily_total = "00:00"})
      
      -- Create an invalid file
      local invalid_path = "/tmp/epoch_test_data/invalid-date.lua"
      local file = io.open(invalid_path, 'w')
      file:write("return {}")
      file:close()
      
      local result = data_loader.get_all_timesheet_dates()
      
      assert.equals(1, #result)
      assert.equals("2025-01-01", result[1])
    end)
  end)
  
  describe("load_timesheets", function()
    it("loads timesheets for given dates", function()
      -- Create test timesheets
      local timesheet1 = {
        date = "2025-01-01",
        intervals = {{client = "test", project = "test", task = "test", start = "9:00 AM"}},
        daily_total = "08:00"
      }
      local timesheet2 = {
        date = "2025-01-02",
        intervals = {{client = "test", project = "test", task = "test", start = "10:00 AM"}},
        daily_total = "08:00"
      }
      
      storage.save_timesheet(timesheet1)
      storage.save_timesheet(timesheet2)
      
      local dates = {"2025-01-01", "2025-01-02"}
      local result = data_loader.load_timesheets(dates)
      
      assert.equals(2, #result)
      assert.equals("2025-01-01", result[1].date)
      assert.equals("2025-01-02", result[2].date)
    end)
    
    it("skips timesheets with no intervals", function()
      -- Create one timesheet with intervals and one without
      storage.save_timesheet({
        date = "2025-01-01",
        intervals = {{client = "test", project = "test", task = "test", start = "9:00 AM"}},
        daily_total = "08:00"
      })
      storage.save_timesheet({
        date = "2025-01-02",
        intervals = {},
        daily_total = "00:00"
      })
      
      local dates = {"2025-01-01", "2025-01-02"}
      local result = data_loader.load_timesheets(dates)
      
      assert.equals(1, #result)
      assert.equals("2025-01-01", result[1].date)
    end)
  end)
end)