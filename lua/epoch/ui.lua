-- epoch/ui.lua
-- ui functionality for epoch time tracking

local ui = {}
local time_utils = require('epoch.time_utils')
local validation = require('epoch.validation')
local storage = require('epoch.storage')

-- Track window and buffer state
local timesheet_buffer = nil
local timesheet_window = nil

-- Set up highlight groups based on current colorscheme
local function setup_highlights()
  -- Get colors from the current colorscheme
  local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
  local normal_fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg
  
  -- Define highlight groups
  local highlights = {
    -- Normal in the epoch window - use normal text/bg colors
    EpochNormal = { default = true, bg = normal_bg, fg = normal_fg },
    
    -- Border highlight - match normal background to avoid the black border
    EpochBorder = { default = true, bg = normal_bg, fg = normal_fg },
    
    -- Title highlight - bold for emphasis
    EpochTitle = { default = true, bg = normal_bg, fg = normal_fg, bold = true },
  }
  
  -- Set up highlight groups
  for k, v in pairs(highlights) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

-- Check if any window is currently open
local function is_window_open()
  return timesheet_window ~= nil and vim.api.nvim_win_is_valid(timesheet_window)
end

-- Parse buffer content to extract timesheet data
local function parse_buffer_content()
  if not timesheet_buffer or not vim.api.nvim_buf_is_valid(timesheet_buffer) then
    return nil, "buffer is not valid"
  end
  
  -- Get buffer content
  local lines = vim.api.nvim_buf_get_lines(timesheet_buffer, 0, -1, false)
  local content = table.concat(lines, "\n")
  
  -- Use protected call to load and execute the Lua content
  local chunk, err = loadstring(content, "timesheet")
  if not chunk then
    return nil, "lua syntax error: " .. tostring(err)
  end
  
  local ok, timesheet = pcall(chunk)
  if not ok then
    return nil, "execution error: " .. tostring(timesheet)
  end
  
  if type(timesheet) ~= "table" then
    return nil, "invalid timesheet format (not a table)"
  end
  
  return timesheet, nil
end

-- Validate and save timesheet content
local function validate_and_save_timesheet()
  -- Parse buffer content
  local timesheet, parse_err = parse_buffer_content()
  if not timesheet then
    vim.notify("epoch: cannot save timesheet - " .. parse_err, vim.log.levels.ERROR)
    return false
  end
  
  -- Validate timesheet structure
  local valid, validation_err = validation.validate_timesheet(timesheet)
  if not valid then
    vim.notify("epoch: validation error - " .. validation_err, vim.log.levels.ERROR)
    return false
  end
  
  -- Get the path for saving
  local path = vim.api.nvim_buf_get_name(timesheet_buffer)
  
  -- Save to file
  local success, save_err = storage.save_timesheet(timesheet)
  if not success then
    vim.notify("epoch: failed to save - " .. tostring(save_err), vim.log.levels.ERROR)
    return false
  end
  
  -- Mark buffer as not modified
  vim.api.nvim_buf_set_option(timesheet_buffer, 'modified', false)
  vim.notify("epoch: timesheet saved", vim.log.levels.INFO)
  return true
end

-- Close window and clean up
local function close_window()
  -- If window is open, close it
  if is_window_open() then
    vim.api.nvim_win_close(timesheet_window, true)
    timesheet_window = nil
  end
  
  -- Clean up buffer
  if timesheet_buffer ~= nil and vim.api.nvim_buf_is_valid(timesheet_buffer) then
    vim.api.nvim_buf_delete(timesheet_buffer, { force = true })
    timesheet_buffer = nil
  end
end

-- Open timesheet window
local function open_timesheet()
  -- Get the timesheet path for today
  local timesheet_path = storage.get_timesheet_path()
  
  -- Create or load the timesheet file
  if vim.fn.filereadable(timesheet_path) == 0 then
    -- Create a default timesheet
    local timesheet = storage.create_default_timesheet()
    storage.save_timesheet(timesheet)
  end
  
  -- Create a new buffer for the file
  timesheet_buffer = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_option(timesheet_buffer, 'bufhidden', 'hide')
  
  -- Set the buffer name and load file content
  vim.api.nvim_buf_set_name(timesheet_buffer, timesheet_path)
  local content = vim.fn.readfile(timesheet_path)
  vim.api.nvim_buf_set_lines(timesheet_buffer, 0, -1, false, content)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(timesheet_buffer, 'filetype', 'lua')
  vim.api.nvim_buf_set_option(timesheet_buffer, 'swapfile', false)
  vim.api.nvim_buf_set_option(timesheet_buffer, 'modifiable', true)
  
  -- Add autocmd for save
  vim.api.nvim_create_autocmd({"BufWriteCmd"}, {
    buffer = timesheet_buffer,
    callback = function()
      validate_and_save_timesheet()
    end
  })
  
  -- Calculate window dimensions (40% width, 70% height)
  local width = math.floor(vim.o.columns * 0.4) 
  local height = math.floor(vim.o.lines * 0.7)
  
  -- Create floating window using direct Neovim API for full control
  timesheet_window = vim.api.nvim_open_win(timesheet_buffer, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = 'epoch - timesheet',
    title_pos = 'center',
  })
  
  -- Set additional window options
  vim.api.nvim_win_set_option(timesheet_window, 'wrap', false)
  vim.api.nvim_win_set_option(timesheet_window, 'winfixheight', true)
  vim.api.nvim_win_set_option(timesheet_window, 'winfixwidth', true)
  
  -- Apply custom highlights
  vim.api.nvim_win_set_option(timesheet_window, 'winhl', 'Normal:EpochNormal,FloatBorder:EpochBorder')
  
  -- Set window-local keymaps
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(timesheet_buffer, 'n', 'q', ':lua require("epoch.ui").toggle_timesheet()<CR>', opts)
  vim.api.nvim_buf_set_keymap(timesheet_buffer, 'n', '<Esc>', ':lua require("epoch.ui").toggle_timesheet()<CR>', opts)
  vim.api.nvim_buf_set_keymap(timesheet_buffer, 'n', 'w', ':w<CR>', opts)
end

-- Set up the UI module
function ui.setup()
  -- Set up highlights
  setup_highlights()
  
  -- Listen for colorscheme changes to update highlights
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      setup_highlights()
    end,
    group = vim.api.nvim_create_augroup("EpochHighlightRefresh", { clear = true }),
  })
  
  -- Handle QuitPre to ensure buffer is saved before Neovim quits
  vim.api.nvim_create_autocmd("QuitPre", {
    callback = function()
      if timesheet_buffer and vim.api.nvim_buf_is_valid(timesheet_buffer) and vim.api.nvim_buf_get_option(timesheet_buffer, 'modified') then
        -- Save the timesheet
        validate_and_save_timesheet()
      end
    end,
    group = vim.api.nvim_create_augroup("EpochQuitHandler", { clear = true }),
  })
end

-- Toggle timesheet window
function ui.toggle_timesheet()
  -- If window is open, validate and save before closing
  if is_window_open() then
    -- If buffer is modified, validate and save
    if vim.api.nvim_buf_get_option(timesheet_buffer, 'modified') then
      if validate_and_save_timesheet() then
        close_window()
      end
      -- If validation fails, keep window open
    else
      -- Not modified, just close
      close_window()
    end
  else
    -- Window not open, check if timesheet exists
    local path = storage.get_timesheet_path()
    
    -- If no timesheet exists, prompt to create one
    if vim.fn.filereadable(path) == 0 then
      ui.add_interval()
    else
      -- Otherwise just open the existing one
      open_timesheet()
    end
  end
end

-- Add a new interval
function ui.add_interval()
  -- Prompt for client and project
  vim.ui.input({ prompt = "client: " }, function(client)
    if not client or client == "" then return end
    
    vim.ui.input({ prompt = "project: " }, function(project)
      if not project or project == "" then return end
      
      vim.ui.input({ prompt = "task: " }, function(task)
        if not task or task == "" then return end
        
        -- Get current time
        local current_time = os.time()
        local current_formatted = time_utils.format_time(current_time)
        
        -- Load or create timesheet
        local timesheet = storage.load_timesheet()
        
        -- Check for previous unclosed interval
        if #timesheet.intervals > 0 then
          local last_interval = timesheet.intervals[#timesheet.intervals]
          
          -- Close it if needed
          if not last_interval.stop or last_interval.stop == "" then
            -- Ensure there's at least a 1-minute difference between intervals
            local last_start_time = time_utils.parse_time(last_interval.start)
            local current_time_obj = os.time()
            
            -- If less than 1 minute has passed, set the end time to 1 minute after start
            if current_time_obj - last_start_time < 60 then
              local adjusted_end_time = last_start_time + 60
              last_interval.stop = time_utils.format_time(adjusted_end_time)
            else
              -- Normal case: use current time
              last_interval.stop = current_formatted
            end
            
            -- Notify about closing the previous interval
            vim.notify("epoch: closed previous interval at " .. last_interval.stop, vim.log.levels.INFO)
          end
        end
        
        -- Determine the start time for the new interval
        local start_time = current_time
        
        -- If we have a previous interval that was just closed
        if #timesheet.intervals > 0 then
          local last_interval = timesheet.intervals[#timesheet.intervals]
          
          -- If the last interval was just closed, ensure new interval starts after it ends
          if last_interval.stop and last_interval.stop ~= "" then
            local last_stop_time = time_utils.parse_time(last_interval.stop)
            
            -- If current time is before or equal to the last stop time, add a minute
            if current_time <= last_stop_time then
              start_time = last_stop_time + 60
            end
          end
        end
        
        -- Create new interval with adjusted start time
        local interval = {
          client = client,
          project = project,
          task = task,
          start = time_utils.format_time(start_time),
          stop = ""
        }
        
        -- Add to timesheet
        table.insert(timesheet.intervals, interval)
        
        -- Update daily total if needed (approximate)
        local closed_minutes = 0
        for _, intvl in ipairs(timesheet.intervals) do
          if intvl.stop and intvl.stop ~= "" then
            -- Add estimated time for this interval
            closed_minutes = closed_minutes + 90 -- Rough estimate
          end
        end
        timesheet.daily_total = time_utils.format_duration(closed_minutes)
        
        -- Save the timesheet
        storage.save_timesheet(timesheet)
        
        -- Notify user
        vim.cmd("redraw!")  -- Clear the screen
        vim.notify("epoch: time tracking started for " .. client .. "/" .. project .. "/" .. task, vim.log.levels.INFO)
        
        -- If the window is open, refresh it
        if is_window_open() then
          -- Update buffer with new content
          local content = storage.serialize_timesheet(timesheet)
          vim.api.nvim_buf_set_lines(timesheet_buffer, 0, -1, false, vim.split(content, '\n'))
          vim.api.nvim_buf_set_option(timesheet_buffer, 'modified', false)
        end
      end)
    end)
  end)
end

return ui