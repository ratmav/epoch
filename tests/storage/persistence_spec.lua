-- tests/storage/persistence_spec.lua

local persistence = require('epoch.storage.persistence')
local paths = require('epoch.storage.paths')
local fixtures = require('fixtures.init')

describe("storage persistence", function()
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

  describe("save_timesheet", function()
    it("saves timesheet to the correct file", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      local file_path = paths.get_timesheet_path(timesheet.date)

      persistence.save_timesheet(timesheet)

      assert.equals(1, vim.fn.filereadable(file_path))
    end)

    it("creates directories if needed", function()
      vim.fn.system("rm -rf /tmp/epoch_test_data")

      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      local file_path = paths.get_timesheet_path(timesheet.date)

      persistence.save_timesheet(timesheet)

      assert.equals(1, vim.fn.filereadable(file_path))
    end)
  end)

  describe("load_timesheet", function()
    it("loads timesheet from file", function()
      local original = fixtures.get('timesheets.valid.with_intervals')
      persistence.save_timesheet(original)

      local loaded = persistence.load_timesheet(original.date)

      assert.equals(original.date, loaded.date)
      assert.equals(#original.intervals, #loaded.intervals)
      assert.equals(original.daily_total, loaded.daily_total)
    end)

    it("returns default timesheet if file doesn't exist", function()
      local date = "2099-01-01"
      local timesheet = persistence.load_timesheet(date)

      assert.equals(date, timesheet.date)
      assert.same({}, timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)

    it("uses today's date when no date is provided", function()
      local today = paths.get_today()
      local timesheet = persistence.load_timesheet()

      assert.equals(today, timesheet.date)
    end)

    it("sorts intervals by start time", function()
      local timesheet = fixtures.get('timesheets.valid.unsorted_intervals')

      persistence.save_timesheet(timesheet)
      local loaded = persistence.load_timesheet(timesheet.date)

      assert.equals("09:00 AM", loaded.intervals[1].start)
      assert.equals("10:45 AM", loaded.intervals[2].start)
    end)
  end)
end)