-- tests/workflow/timesheet_spec.lua
-- Integration tests for complete timesheet workflows

local timesheet_workflow = require('epoch.workflow.timesheet')
local storage = require('epoch.storage')
local fixtures = require('fixtures')

describe("workflow timesheet", function()

  describe("validate_content workflow", function()
    it("should complete full validation workflow for valid content", function()
      local content = fixtures.get('ui.buffer_content.valid_timesheet')
      local timesheet, err = timesheet_workflow.validate_content(content)

      assert.is_nil(err)
      assert.is_table(timesheet)
      assert.equals("2025-05-12", timesheet.date)
      assert.equals(2, #timesheet.intervals)
      -- Should have recalculated hours for complete intervals
      for _, interval in ipairs(timesheet.intervals) do
        if interval.start and interval.stop and interval.stop ~= "" then
          assert.is_number(interval.hours)
        end
      end
    end)

    it("should handle complete validation failure workflow", function()
      local content = fixtures.get('ui.buffer_content.missing_field')
      local timesheet, err = timesheet_workflow.validate_content(content)

      assert.is_nil(timesheet)
      assert.is_string(err)
      assert.matches("[cC]annot be empty", err)
    end)

    it("should handle parse error workflow", function()
      local malformed_content = "return { invalid syntax"
      local timesheet, err = timesheet_workflow.validate_content(malformed_content)

      assert.is_nil(timesheet)
      assert.is_string(err)
      assert.matches("lua syntax error", err)
    end)

    it("should handle type validation workflow", function()
      local non_table_content = [[return "not a table"]]
      local timesheet, err = timesheet_workflow.validate_content(non_table_content)

      assert.is_nil(timesheet)
      assert.equals("timesheet must be a table", err)
    end)
  end)

  describe("add_to_timesheet workflow", function()
    it("should complete full interval addition workflow", function()
      -- Start with empty timesheet
      local timesheet = fixtures.get('timesheets.valid.empty')
      local new_interval = fixtures.get('intervals.valid.frontend')

      -- Execute complete workflow
      local result = timesheet_workflow.add_to_timesheet(timesheet, new_interval)

      assert.equals(1, #result.intervals)
      assert.same(new_interval, result.intervals[1])
      -- Original timesheet should not be modified (immutable)
      assert.equals(0, #timesheet.intervals)
    end)

    it("should complete workflow with interval closing", function()
      -- Start with timesheet containing open interval
      local timesheet = fixtures.get('timesheets.valid.with_unclosed_intervals')
      local new_interval = fixtures.get('intervals.valid.backend')

      -- Mock time for predictable testing
      local original_time = os.time
      os.time = function() return 1620123000 end

      local result = timesheet_workflow.add_to_timesheet(timesheet, new_interval)

      -- Restore original time function
      os.time = original_time

      assert.equals(2, #result.intervals)
      -- First interval should be closed
      assert.not_equals("", result.intervals[1].stop)
      -- Second interval should be the new one
      assert.same(new_interval, result.intervals[2])
    end)
  end)

  describe("ensure_timesheet_exists workflow", function()
    it("should create timesheet when file doesn't exist", function()
      local test_date = "2025-01-01"
      local expected_path = storage.get_timesheet_path(test_date)
      
      -- Clean up any existing file first
      if vim.fn.filereadable(expected_path) == 1 then
        os.remove(expected_path)
      end
      
      -- Ensure file doesn't exist
      assert.equals(0, vim.fn.filereadable(expected_path))
      
      timesheet_workflow.ensure_timesheet_exists(expected_path, test_date)
      
      -- File should now exist
      assert.equals(1, vim.fn.filereadable(expected_path))
      
      -- Clean up
      os.remove(expected_path)
    end)
  end)
end)