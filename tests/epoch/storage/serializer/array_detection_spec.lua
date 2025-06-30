-- tests/storage/serializer/array_detection_spec.lua

local array_detection = require('epoch.storage.serializer.array_detection')
local fixtures = require('fixtures.init')

describe("storage serializer array_detection", function()
  describe("is_array", function()
    it("returns true for arrays", function()
      assert.is_true(array_detection.is_array(fixtures.get('storage.arrays.empty')))
      assert.is_true(array_detection.is_array(fixtures.get('storage.arrays.single_item')))
      assert.is_true(array_detection.is_array(fixtures.get('storage.arrays.strings')))
      assert.is_true(array_detection.is_array(fixtures.get('storage.arrays.mixed_types')))
    end)

    it("returns false for non-arrays", function()
      assert.is_false(array_detection.is_array(fixtures.get('storage.non_arrays.object')))
      assert.is_false(array_detection.is_array(fixtures.get('storage.non_arrays.sparse')))
      assert.is_false(array_detection.is_array(fixtures.get('storage.non_arrays.mixed_keys')))
      assert.is_false(array_detection.is_array(fixtures.get('storage.non_arrays.string')))
      assert.is_false(array_detection.is_array(nil))
      assert.is_false(array_detection.is_array(fixtures.get('storage.non_arrays.number')))
    end)

    it("returns false for sparse arrays", function()
      assert.is_false(array_detection.is_array(fixtures.get('storage.non_arrays.sparse')))
    end)
  end)
end)