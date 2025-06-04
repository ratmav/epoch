-- tests/validation/fields/context_spec.lua

local context = require('epoch.validation.fields.context')
local fixtures = require('fixtures.init')

describe("validation fields context", function()
  describe("get_interval_context", function()
    it("should generate context for complete intervals", function()
      local interval_context = context.get_interval_context(fixtures.get('intervals.valid.frontend'))

      assert.equals("acme-corp/website-redesign/frontend-planning/09:00 AM", interval_context)
    end)

    it("should generate context for partial intervals", function()
      local interval_context = context.get_interval_context(fixtures.get('intervals.test.partial'))

      assert.equals("test-client/test-project", interval_context)
    end)

    it("should handle empty intervals", function()
      local interval_context = context.get_interval_context({})

      assert.equals("unknown interval", interval_context)
    end)

    it("should handle nil intervals", function()
      local interval_context = context.get_interval_context(nil)

      assert.equals("unknown interval", interval_context)
    end)

    it("should generate context with all fields", function()
      local interval_context = context.get_interval_context(fixtures.get('intervals.test.complete'))

      assert.equals("client/project/task/10:00 AM", interval_context)
    end)
  end)
end)