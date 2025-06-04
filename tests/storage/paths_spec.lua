-- tests/storage/paths_spec.lua

local paths = require('epoch.storage.paths')

describe("storage paths", function()
  -- Set up a test data directory for isolation
  before_each(function()
    paths.set_data_dir("/tmp/epoch_test_data")
    vim.fn.mkdir("/tmp/epoch_test_data", "p")
  end)

  -- Clean up after tests
  after_each(function()
    vim.fn.system("rm -rf /tmp/epoch_test_data")
  end)

  describe("get_data_dir", function()
    it("returns the configured data directory", function()
      assert.equals("/tmp/epoch_test_data", paths.get_data_dir())
    end)
  end)

  describe("get_today", function()
    it("returns today's date in YYYY-MM-DD format", function()
      local date = paths.get_today()
      assert.matches("%d%d%d%d%-%d%d%-%d%d", date)
    end)
  end)

  describe("get_timesheet_path", function()
    it("returns the correct path for a given date", function()
      local date = "2025-05-12"
      local expected_path = "/tmp/epoch_test_data/2025-05-12.lua"

      assert.equals(expected_path, paths.get_timesheet_path(date))
    end)

    it("uses today's date when no date is provided", function()
      local today = paths.get_today()
      local expected_path = "/tmp/epoch_test_data/" .. today .. ".lua"

      assert.equals(expected_path, paths.get_timesheet_path())
    end)
  end)

  describe("ensure_data_dir", function()
    it("creates the data directory if it doesn't exist", function()
      vim.fn.system("rm -rf /tmp/epoch_test_data")

      paths.ensure_data_dir()
      assert.equals(1, vim.fn.isdirectory("/tmp/epoch_test_data"))
    end)
  end)
end)