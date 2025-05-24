-- ui_helpers.lua
-- helper functions for UI testing

local ui_helpers = {}

-- Helper to create a mock buffer with content
function ui_helpers.create_mock_buffer(content)
  local bufnr = vim.api.nvim_create_buf(false, true)
  
  if content then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, '\n'))
  end
  
  return bufnr
end

-- Helper to create a mock window with specified configuration
function ui_helpers.create_mock_window(bufnr, config)
  local width_pct = config.width_percentage or 0.4
  local height_pct = config.height_percentage or 0.8
  
  local width = math.floor(vim.o.columns * width_pct)
  local height = math.floor(vim.o.lines * height_pct)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = config.style or 'minimal',
    border = config.border or 'rounded',
    title = config.title,
    title_pos = config.title_pos or 'center',
  }
  
  return vim.api.nvim_open_win(bufnr, true, win_config)
end

-- Helper to mock notification system for testing
function ui_helpers.create_notification_mock()
  local notifications = {}
  local original_notify = vim.notify
  
  -- Override vim.notify to capture notifications
  vim.notify = function(msg, level, opts)
    table.insert(notifications, {
      message = msg,
      level = level or vim.log.levels.INFO,
      opts = opts or {}
    })
  end
  
  return {
    -- Get captured notifications
    get_notifications = function()
      return notifications
    end,
    
    -- Reset captured notifications
    reset = function()
      notifications = {}
    end,
    
    -- Restore original notify function
    restore = function()
      vim.notify = original_notify
    end
  }
end

-- Setup a full UI testing environment
function ui_helpers.setup_ui_test(content, window_config)
  local bufnr = ui_helpers.create_mock_buffer(content)
  local winnr = ui_helpers.create_mock_window(bufnr, window_config or {})
  
  -- Return context with cleanup function
  return {
    buffer = bufnr,
    window = winnr,
    
    -- Function to clean up
    cleanup = function()
      if vim.api.nvim_win_is_valid(winnr) then
        vim.api.nvim_win_close(winnr, true)
      end
      
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end
  }
end

return ui_helpers