-- tests/validation/time_utils_spec.lua

local time_utils = require('epoch.validation.time_utils')

describe("validation time_utils", function()
  describe("time_value", function()
    it("should convert valid AM times to minutes since midnight", function()
      assert.equals(0, time_utils.time_value("12:00 AM"))
      assert.equals(60, time_utils.time_value("1:00 AM"))
      assert.equals(570, time_utils.time_value("9:30 AM"))
      assert.equals(719, time_utils.time_value("11:59 AM"))
    end)

    it("should convert valid PM times to minutes since midnight", function()
      assert.equals(720, time_utils.time_value("12:00 PM"))
      assert.equals(780, time_utils.time_value("1:00 PM"))
      assert.equals(1110, time_utils.time_value("6:30 PM"))
      assert.equals(1439, time_utils.time_value("11:59 PM"))
    end)

    it("should return nil for invalid time formats", function()
      assert.is_nil(time_utils.time_value("25:00 AM"))
      assert.is_nil(time_utils.time_value("12:60 PM"))
      assert.is_nil(time_utils.time_value("0:30 AM"))
      assert.is_nil(time_utils.time_value("not a time"))
      assert.is_nil(time_utils.time_value(""))
      assert.is_nil(time_utils.time_value(nil))
    end)

    it("should handle edge cases correctly", function()
      assert.equals(720, time_utils.time_value("12:00 PM"))  -- Noon
      assert.equals(0, time_utils.time_value("12:00 AM"))    -- Midnight
    end)
  end)
end)