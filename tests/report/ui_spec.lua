-- tests/report/ui_spec.lua

local ui = require('epoch.report.ui')
local window = require('epoch.ui.window')

describe("report ui", function()
  describe("toggle_report", function()
    it("opens window when not open", function()
      -- Mock window.is_open to return false
      local original_is_open = window.is_open
      local original_create = window.create
      local create_called = false
      
      window.is_open = function(id)
        return false
      end
      
      window.create = function(config)
        create_called = true
        assert.equals("report", config.id)
        assert.equals("epoch - report", config.title)
        assert.equals(0.5, config.width_percent)
        assert.equals(0.6, config.height_percent)
        assert.equals("markdown", config.filetype)
        assert.is_false(config.modifiable)
        assert.is_string(config.content)
      end
      
      ui.toggle_report()
      
      assert.is_true(create_called)
      
      -- Restore original functions
      window.is_open = original_is_open
      window.create = original_create
    end)
    
    it("closes window when already open", function()
      -- Mock window.is_open to return true
      local original_is_open = window.is_open
      local original_close = window.close
      local close_called = false
      
      window.is_open = function(id)
        return true
      end
      
      window.close = function(id)
        close_called = true
        assert.equals("report", id)
      end
      
      ui.toggle_report()
      
      assert.is_true(close_called)
      
      -- Restore original functions
      window.is_open = original_is_open
      window.close = original_close
    end)
  end)
end)