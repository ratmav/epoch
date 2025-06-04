-- tests/storage/serializer_spec.lua

local serializer = require('epoch.storage.serializer')
local fixtures = require('fixtures.init')

describe("storage serializer", function()
  describe("serialize_timesheet", function()
    it("serializes timesheet to a valid Lua string", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      local lua_string = serializer.serialize_timesheet(timesheet)

      local chunk, err = loadstring(lua_string)
      assert.is_nil(err)
      assert.is_function(chunk)

      local result = chunk()
      assert.is_table(result)
      assert.equals(timesheet.date, result.date)
      assert.equals(#timesheet.intervals, #result.intervals)
    end)

    it("formats intervals with ordered keys", function()
      local timesheet = fixtures.get('timesheets.valid.with_intervals')
      local lua_string = serializer.serialize_timesheet(timesheet)

      assert.truthy(lua_string:match('client'))
      assert.truthy(lua_string:match('project'))
      assert.truthy(lua_string:match('task'))
      assert.truthy(lua_string:match('start'))
      assert.truthy(lua_string:match('stop'))
      assert.truthy(lua_string:match('notes'))
    end)

    it("properly serializes intervals with notes", function()
      local timesheet = fixtures.get('timesheets.valid.with_interval_with_notes')
      local lua_string = serializer.serialize_timesheet(timesheet)

      local chunk = loadstring(lua_string)
      local result = chunk()

      assert.is_table(result.intervals[1].notes)
      assert.equals(2, #result.intervals[1].notes)
      assert.equals("Added API documentation", result.intervals[1].notes[1])
      assert.equals("Reviewed with team", result.intervals[1].notes[2])
    end)
  end)
end)