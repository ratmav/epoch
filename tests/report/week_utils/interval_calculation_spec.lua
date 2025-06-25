-- tests/report/week_utils/interval_calculation_spec.lua

local interval_calculation = require('epoch.report.week_utils.interval_calculation')

describe("report week_utils interval_calculation", function()
  describe("get_interval_hours", function()
    it("gets hours from completed intervals with hours field", function()
      local interval = {
        client = "test",
        project = "test", 
        task = "test",
        start = "9:00 AM",
        stop = "10:30 AM",
        hours = 1.5
      }

      local hours = interval_calculation.get_interval_hours(interval)
      assert.equals(1.5, hours)
    end)

    it("returns 0 for intervals without hours field", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "9:00 AM",
        stop = "10:30 AM"
      }

      local hours = interval_calculation.get_interval_hours(interval)
      assert.equals(0, hours)
    end)

    it("returns 0 for intervals with nil hours field", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "9:00 AM",
        stop = "10:30 AM",
        hours = nil
      }

      local hours = interval_calculation.get_interval_hours(interval)
      assert.equals(0, hours)
    end)

    it("handles intervals with zero hours", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "9:00 AM",
        stop = "9:00 AM",
        hours = 0
      }

      local hours = interval_calculation.get_interval_hours(interval)
      assert.equals(0, hours)
    end)

    it("handles intervals with decimal hours", function()
      local interval = {
        client = "test",
        project = "test",
        task = "test",
        start = "9:00 AM",
        stop = "10:45 AM",
        hours = 1.75
      }

      local hours = interval_calculation.get_interval_hours(interval)
      assert.equals(1.75, hours)
    end)
  end)
end)