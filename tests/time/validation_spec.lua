-- tests/time_utils/validation_spec.lua

local validation = require('epoch.time.validation')

describe("time_utils validation", function()
  describe("is_valid_time_format", function()
    it("validates correct 12-hour time formats", function()
      local valid_formats = fixtures.get('time.validation.valid_formats')
      for _, time_format in ipairs(valid_formats) do
        assert.is_true(validation.is_valid_time_format(time_format))
      end
    end)

    it("rejects invalid time formats", function()
      local invalid_formats = fixtures.get('time.validation.invalid_formats')
      for _, time_format in ipairs(invalid_formats) do
        assert.is_false(validation.is_valid_time_format(time_format))
      end
    end)

    it("requires proper spacing and case", function()
      local invalid_spacing = fixtures.get('time.validation.invalid_spacing_case')
      for _, time_format in ipairs(invalid_spacing) do
        assert.is_false(validation.is_valid_time_format(time_format))
      end
    end)
  end)
end)