-- tests/validation/overlap/adjacent_pairs_spec.lua

local adjacent_pairs = require('epoch.validation.overlap.adjacent_pairs')
local fixtures = require('fixtures.init')

describe("validation overlap adjacent_pairs", function()
  describe("check", function()
    it("detects overlapping intervals", function()
      local overlapping = fixtures.get('intervals.invalid.overlapping')
      local is_overlapping, msg = adjacent_pairs.check(overlapping)

      assert.is_true(is_overlapping)
      assert.truthy(msg:match("intervals overlap"))
    end)

    it("detects when unclosed interval start time overlaps with existing interval", function()
      local overlapping_unclosed = fixtures.get('intervals.invalid.overlapping_unclosed')
      local is_overlapping, msg = adjacent_pairs.check(overlapping_unclosed)

      assert.is_true(is_overlapping)
      assert.truthy(msg:match("intervals overlap"))
    end)

    it("accepts non-overlapping unclosed intervals", function()
      local non_overlapping_unclosed = fixtures.get('intervals.valid')
      local is_overlapping, _ = adjacent_pairs.check(non_overlapping_unclosed)

      assert.is_false(is_overlapping)
    end)

    it("accepts non-overlapping intervals", function()
      local non_overlapping = fixtures.get('intervals.valid')
      local is_overlapping, _ = adjacent_pairs.check(non_overlapping)

      assert.is_false(is_overlapping)
    end)

    it("handles empty or single intervals", function()
      local empty = {}
      local is_overlapping, _ = adjacent_pairs.check(empty)
      assert.is_false(is_overlapping)

      local single = { fixtures.get('intervals.valid')[1] }
      is_overlapping, _ = adjacent_pairs.check(single)
      assert.is_false(is_overlapping)
    end)
  end)
end)