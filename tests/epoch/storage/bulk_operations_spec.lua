-- tests/storage/bulk_operations_spec.lua

local bulk_operations = require('epoch.storage.bulk_operations')
local discovery = require('epoch.storage.discovery')
local paths = require('epoch.storage.paths')
local persistence = require('epoch.storage.persistence')

describe("storage bulk_operations", function()
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

  describe("delete_all_timesheets", function()
    it("deletes all timesheet files", function()
      local dates = fixtures.get('time.date_arrays.storage_test_dates')
      for _, date in ipairs(dates) do
        local timesheet = vim.deepcopy(fixtures.get('timesheets.valid.empty'))
        timesheet.date = date
        persistence.save_timesheet(timesheet)
      end

      local before = discovery.get_all_timesheet_files()
      assert.equals(#dates, #before)

      local count = bulk_operations.delete_all_timesheets()
      assert.equals(#dates, count)

      local after = discovery.get_all_timesheet_files()
      assert.same({}, after)
    end)

    it("returns 0 when no files exist", function()
      vim.fn.system("rm -f /tmp/epoch_test_data/*.lua")

      local count = bulk_operations.delete_all_timesheets()
      assert.equals(0, count)
    end)
  end)
end)