-- tests/validation/overlap_spec.lua

local validation = require('epoch.validation')
local overlap = require('epoch.validation.overlap')

describe("validation overlap", function()
  describe("public interface delegation", function()
    it("delegates check_overlapping_intervals to validation module", function()
      -- Test that the public interface works through delegation
      local empty = {}
      local is_overlapping, _ = validation.check_overlapping_intervals(empty)
      assert.is_false(is_overlapping)
    end)

    it("delegates check_multiple_open_intervals through overlap module", function()
      -- Test that the overlap module interface works through delegation
      local empty = {}
      local has_multiple, _ = overlap.check_multiple_open_intervals(empty)
      assert.is_false(has_multiple)
    end)
  end)
end)