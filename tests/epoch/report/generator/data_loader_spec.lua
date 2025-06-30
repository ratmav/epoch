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
        local timesheet = vim.deepcopy(fixtures.get('reports.test_timesheets.basic_empty'))
        timesheet.date = date
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
      local timesheet = vim.deepcopy(fixtures.get('reports.test_timesheets.basic_empty'))
      timesheet.date = "2025-01-01"
      storage.save_timesheet(timesheet)

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
      local timesheet1 = vim.deepcopy(fixtures.get('reports.test_timesheets.basic_with_interval'))
      timesheet1.date = "2025-01-01"
      local timesheet2 = vim.deepcopy(fixtures.get('reports.test_timesheets.basic_with_interval_2'))
      timesheet2.date = "2025-01-02"

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
      local timesheet_with_intervals = vim.deepcopy(fixtures.get('reports.test_timesheets.basic_with_interval'))
      timesheet_with_intervals.date = "2025-01-01"
      storage.save_timesheet(timesheet_with_intervals)

      local timesheet_empty = vim.deepcopy(fixtures.get('reports.test_timesheets.basic_empty'))
      timesheet_empty.date = "2025-01-02"
      storage.save_timesheet(timesheet_empty)

      local dates = {"2025-01-01", "2025-01-02"}
      local result = data_loader.load_timesheets(dates)

      assert.equals(1, #result)
      assert.equals("2025-01-01", result[1].date)
    end)
  end)
end)