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

  describe("extract_date_from_filename", function()
    it("extracts date from valid timesheet file path", function()
      local filepath = "/home/user/.local/share/nvim/epoch/2024-01-15.lua"
      local date = paths.extract_date_from_filename(filepath)
      assert.equals("2024-01-15", date)
    end)

    it("extracts date from filename only", function()
      local filepath = "2024-12-25.lua"
      local date = paths.extract_date_from_filename(filepath)
      assert.equals("2024-12-25", date)
    end)

    it("returns nil for invalid date format", function()
      local filepath = "/home/user/invalid-file.lua"
      local date = paths.extract_date_from_filename(filepath)
      assert.is_nil(date)
    end)

    it("extracts date regardless of file extension", function()
      local filepath = "/home/user/2024-01-15.txt"
      local date = paths.extract_date_from_filename(filepath)
      assert.equals("2024-01-15", date)
    end)

    it("returns nil for malformed date patterns", function()
      local test_cases = {
        "24-01-15.lua",     -- wrong year format
        "2024-1-15.lua",    -- missing zero padding
        "2024-01-5.lua",    -- missing zero padding
        "not-a-date.lua"    -- completely wrong format
      }

      for _, filepath in ipairs(test_cases) do
        local date = paths.extract_date_from_filename(filepath)
        assert.is_nil(date, "Expected nil for: " .. filepath)
      end
    end)

    it("extracts valid patterns including invalid calendar dates", function()
      local test_cases = {
        { "2024-13-01.lua", "2024-13-01" },   -- invalid month but valid pattern
        { "2024-01-32.lua", "2024-01-32" },   -- invalid day but valid pattern
      }

      for _, case in ipairs(test_cases) do
        local date = paths.extract_date_from_filename(case[1])
        assert.equals(case[2], date)
      end
    end)
  end)
end)
