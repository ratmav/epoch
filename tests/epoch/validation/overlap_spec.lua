-- tests/validation/overlap_spec.lua

local validation = require('epoch.validation')
local fixtures = require('fixtures.init')

describe("validation overlap", function()
  describe("check_overlapping_intervals", function()
    it("detects overlapping intervals", function()
      local overlapping = fixtures.get('intervals.invalid.overlapping')
      local is_overlapping, msg = validation.check_overlapping_intervals(overlapping)

      assert.is_true(is_overlapping)
      assert.truthy(msg:match("intervals overlap"))
    end)

    it("detects when unclosed interval start time overlaps with existing interval", function()
      local overlapping_unclosed = fixtures.get('intervals.invalid.overlapping_unclosed')
      local is_overlapping, msg = validation.check_overlapping_intervals(overlapping_unclosed)

      assert.is_true(is_overlapping)
      assert.truthy(msg:match("intervals overlap"))
    end)

    it("accepts non-overlapping unclosed intervals", function()
      local non_overlapping_unclosed = fixtures.get('intervals.valid')
      local is_overlapping, _ = validation.check_overlapping_intervals(non_overlapping_unclosed)

      assert.is_false(is_overlapping)
    end)

    it("accepts non-overlapping intervals", function()
      local non_overlapping = fixtures.get('intervals.valid')
      local is_overlapping, _ = validation.check_overlapping_intervals(non_overlapping)

      assert.is_false(is_overlapping)
    end)

    it("handles empty or single intervals", function()
      local empty = {}
      local is_overlapping, _ = validation.check_overlapping_intervals(empty)
      assert.is_false(is_overlapping)

      local single = { fixtures.get('intervals.valid')[1] }
      is_overlapping, _ = validation.check_overlapping_intervals(single)
      assert.is_false(is_overlapping)
    end)
  end)
end)