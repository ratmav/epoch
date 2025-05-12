-- storage_spec.lua
-- tests for the storage module

describe("storage", function()
  local storage = require('epoch.storage')

  describe("create_default_timesheet", function()
    it("creates a timesheet with default values", function()
      local date = "2025-05-12"
      local timesheet = storage.create_default_timesheet(date)

      assert.equals(date, timesheet.date)
      assert.same({}, timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)

    it("uses current date when no date is provided", function()
      local timesheet = storage.create_default_timesheet()

      -- Just verify structure, not actual date value
      assert.is_string(timesheet.date)
      assert.matches("%d%d%d%d%-%d%d%-%d%d", timesheet.date)
      assert.same({}, timesheet.intervals)
      assert.equals("00:00", timesheet.daily_total)
    end)
  end)

  describe("serialize_timesheet", function()
    it("serializes timesheet to a valid Lua string", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
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
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
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
      local timesheet = fixtures.get('timesheets.valid.with_interval_with_notes')
      local lua_string = storage.serialize_timesheet(timesheet)

      -- Test serialization/deserialization round-trip
      local chunk = loadstring(lua_string)
      local result = chunk()

      -- Verify notes are preserved in serialization
      assert.is_table(result.intervals[1].notes)
      assert.equals(2, #result.intervals[1].notes)
      assert.equals("Added API documentation", result.intervals[1].notes[1])
      assert.equals("Reviewed with team", result.intervals[1].notes[2])
    end)
  end)
end)