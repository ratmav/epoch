-- tests/validation/fields/interval_spec.lua

local validation = require('epoch.validation')

describe("validation fields interval", function()
  describe("validate_interval", function()
    it("validates valid intervals", function()
      for _, interval in ipairs(fixtures.get('intervals.valid')) do
        local is_valid, _ = validation.validate_interval(interval)
        assert.is_true(is_valid)
      end
    end)

    it("rejects intervals with missing client", function()
      local is_valid, err = validation.validate_interval(fixtures.get('intervals.invalid.missing_client'))
      assert.is_false(is_valid)
      assert.truthy(err:match("client cannot be empty"))
    end)

    it("rejects intervals with missing project", function()
      local is_valid, err = validation.validate_interval(fixtures.get('intervals.invalid.missing_project'))
      assert.is_false(is_valid)
      assert.truthy(err:match("project cannot be empty"))
    end)

    it("rejects intervals with missing task", function()
      local is_valid, err = validation.validate_interval(fixtures.get('intervals.invalid.missing_task'))
      assert.is_false(is_valid)
      assert.truthy(err:match("task cannot be empty"))
    end)

    it("rejects intervals with invalid time formats", function()
      local is_valid, err = validation.validate_interval(fixtures.get('intervals.invalid.invalid_time'))
      assert.is_false(is_valid)
      assert.truthy(err:match("must be in format"))
    end)

    it("rejects intervals with missing notes", function()
      local is_valid, err = validation.validate_interval(fixtures.get('intervals.invalid.missing_notes'))
      assert.is_false(is_valid)
      assert.truthy(err:match("notes field is required"))
    end)

    it("rejects intervals with invalid notes type", function()
      local is_valid, err = validation.validate_interval(fixtures.get('intervals.invalid.invalid_notes_type'))
      assert.is_false(is_valid)
      assert.truthy(err:match("notes must be an array of strings"))
    end)

    it("rejects intervals with invalid notes entries", function()
      local is_valid, err = validation.validate_interval(fixtures.get('intervals.invalid.invalid_notes_entries'))
      assert.is_false(is_valid)
      assert.truthy(err:match("note at position"))
    end)

    it("validates intervals with proper notes array", function()
      local is_valid, _ = validation.validate_interval(fixtures.get('intervals.valid.with_notes'))
      assert.is_true(is_valid)
    end)

    it("handles non-table inputs gracefully", function()
      local is_valid, err = validation.validate_interval(nil)
      assert.is_false(is_valid)
      assert.truthy(err:match("interval must be a table"))

      is_valid, err = validation.validate_interval("not a table")
      assert.is_false(is_valid)
      assert.truthy(err:match("interval must be a table"))
    end)
  end)
end)