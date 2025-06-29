-- tests/epoch/models/interval/calculation_spec.lua

local calculation = require('epoch.models.interval.calculation')

describe("models interval calculation", function()
  describe("calculate_duration_minutes", function()
    it("should calculate minutes for complete interval", function()
      local interval = fixtures.get('intervals.valid.frontend')

      local minutes = calculation.calculate_duration_minutes(interval)

      assert.equals(90, minutes)
    end)

    it("should return 0 for incomplete interval", function()
      local interval = fixtures.get('intervals.invalid.unclosed')

      local minutes = calculation.calculate_duration_minutes(interval)

      assert.equals(0, minutes)
    end)

    it("should return 0 for interval with invalid times", function()
      local interval = fixtures.get('intervals.invalid.invalid_time')

      local minutes = calculation.calculate_duration_minutes(interval)

      assert.equals(0, minutes)
    end)

    it("should handle negative duration by returning 0", function()
      local interval = fixtures.get('intervals.invalid.negative_duration_interval')

      local minutes = calculation.calculate_duration_minutes(interval)

      assert.equals(0, minutes)
    end)
  end)
end)