-- tests/workflow/integration_spec.lua
-- Cross-workflow integration tests

local timesheet_workflow = require('epoch.workflow.timesheet')
local interval_workflow = require('epoch.workflow.interval')
local storage = require('epoch.storage')
local fixtures = require('fixtures')

describe("workflow integration", function()

  describe("complete user scenarios", function()
    it("should handle complete timesheet creation and interval addition workflow", function()
      -- Scenario: User creates new timesheet and adds multiple intervals
      local test_date = "2025-06-25"
      local default_timesheet = storage.create_default_timesheet(test_date)
      
      -- Add first interval
      local success1, err1, timesheet_v1 = interval_workflow.add_interval(
        "acme-corp", "website", "planning", default_timesheet
      )
      
      assert.is_true(success1)
      assert.is_nil(err1)
      assert.equals(1, #timesheet_v1.intervals)
      assert.equals("", timesheet_v1.intervals[1].stop) -- Open interval
      
      -- Add second interval (should close first)
      local success2, err2, timesheet_v2 = interval_workflow.add_interval(
        "beta-inc", "mobile-app", "development", timesheet_v1
      )
      
      assert.is_true(success2)
      assert.is_nil(err2)
      assert.equals(2, #timesheet_v2.intervals)
      assert.not_equals("", timesheet_v2.intervals[1].stop) -- First closed
      assert.equals("", timesheet_v2.intervals[2].stop) -- Second open
      
      -- Validate final timesheet structure
      local serialized = storage.serialize_timesheet(timesheet_v2)
      local validated, validation_err = timesheet_workflow.validate_content(serialized)
      
      assert.is_nil(validation_err)
      assert.is_table(validated)
      assert.equals(test_date, validated.date)
      assert.equals(2, #validated.intervals)
    end)

    it("should handle interval addition with timesheet validation workflow", function()
      -- Scenario: User adds interval to existing timesheet content
      local content = fixtures.get('ui.buffer_content.valid_timesheet')
      
      -- Parse and validate existing content
      local timesheet, parse_err = timesheet_workflow.validate_content(content)
      assert.is_nil(parse_err)
      
      local original_count = #timesheet.intervals
      
      -- Add new interval through workflow
      local success, add_err, updated = interval_workflow.add_interval(
        "new-client", "new-project", "new-task", timesheet
      )
      
      assert.is_true(success)
      assert.is_nil(add_err)
      assert.equals(original_count + 1, #updated.intervals)
      
      -- Validate updated timesheet
      local final_content = storage.serialize_timesheet(updated)
      local final_timesheet, final_err = timesheet_workflow.validate_content(final_content)
      
      assert.is_nil(final_err)
      assert.equals(original_count + 1, #final_timesheet.intervals)
    end)

    it("should handle error propagation across workflow boundaries", function()
      -- Scenario: Validation error should prevent interval addition
      local invalid_timesheet = { 
        date = nil, -- Invalid: missing date
        intervals = {},
        daily_total = "00:00"
      }
      
      -- This should fail validation if we serialize and re-parse
      local content = storage.serialize_timesheet(invalid_timesheet)
      local validated, validation_err = timesheet_workflow.validate_content(content)
      
      assert.is_nil(validated)
      assert.is_string(validation_err)
      assert.matches("date", validation_err:lower())
    end)

    it("should maintain data consistency across multiple workflow operations", function()
      -- Scenario: Multiple operations should maintain consistent state
      local timesheet = fixtures.get('timesheets.valid.empty')
      
      -- Perform series of interval additions
      local clients = {"client-a", "client-b", "client-c"}
      local current_timesheet = timesheet
      
      for i, client in ipairs(clients) do
        local success, err, updated = interval_workflow.add_interval(
          client, "project-" .. i, "task-" .. i, current_timesheet
        )
        
        assert.is_true(success)
        assert.is_nil(err)
        assert.equals(i, #updated.intervals)
        
        -- Validate consistency
        assert.equals(client, updated.intervals[i].client)
        if i > 1 then
          -- Previous intervals should be closed
          assert.not_equals("", updated.intervals[i-1].stop)
        end
        -- Current interval should be open
        assert.equals("", updated.intervals[i].stop)
        
        current_timesheet = updated
      end
      
      -- Final validation
      local final_content = storage.serialize_timesheet(current_timesheet)
      local final_validated, final_err = timesheet_workflow.validate_content(final_content)
      
      assert.is_nil(final_err)
      assert.equals(#clients, #final_validated.intervals)
    end)
  end)

  describe("workflow coordination", function()
    it("should coordinate timesheet and interval workflows seamlessly", function()
      -- Test that timesheet workflow can process intervals created by interval workflow
      local base_timesheet = fixtures.get('timesheets.valid.empty')
      
      -- Create interval through interval workflow
      local success, err, timesheet_with_interval = interval_workflow.add_interval(
        "test-client", "test-project", "test-task", base_timesheet
      )
      
      assert.is_true(success)
      
      -- Process through timesheet workflow
      local serialized = storage.serialize_timesheet(timesheet_with_interval)
      local validated, validation_err = timesheet_workflow.validate_content(serialized)
      
      assert.is_nil(validation_err)
      assert.is_table(validated)
      
      -- Should have hours calculated for closed intervals
      for _, interval in ipairs(validated.intervals) do
        if interval.stop and interval.stop ~= "" then
          assert.is_number(interval.hours)
        end
      end
    end)
  end)
end)