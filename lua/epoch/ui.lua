-- epoch/ui.lua
-- user interface for epoch time tracking

local ui = {}

local config = require('epoch.config')
local timeops = require('epoch.timeops')
local storage = require('epoch.storage')

local timesheet_buffer = nil
local timesheet_window = nil

-- setup highlight groups based on current colorscheme
local function setup_highlights()
  -- get colors from the current colorscheme
  local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
  local normal_fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg
  
  -- define highlight groups
  local highlights = {
    -- normal in the epoch window - use normal text/bg colors
    EpochNormal = { default = true, bg = normal_bg, fg = normal_fg },
    
    -- border highlight - match normal background
    EpochBorder = { default = true, bg = normal_bg, fg = normal_fg },
    
    -- title highlight - bold for emphasis
    EpochTitle = { default = true, bg = normal_bg, fg = normal_fg, bold = true },
  }
  
  -- setup highlight groups
  for k, v in pairs(highlights) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

-- initial highlight setup
setup_highlights()

-- check if any window is currently open (either timesheet or report)
local function is_window_open()
  return timesheet_window ~= nil and vim.api.nvim_win_is_valid(timesheet_window)
end

-- close any open window and clean up its buffer
local function close_window()

  -- Check if the buffer is modified and needs validation
  if timesheet_buffer ~= nil and
     vim.api.nvim_buf_is_valid(timesheet_buffer) and
     vim.api.nvim_buf_get_option(timesheet_buffer, 'modified') then

    -- Get the buffer content
    local lines = vim.api.nvim_buf_get_lines(timesheet_buffer, 0, -1, false)
    local lua_content = table.concat(lines, "\n")
    local timesheet_path = vim.api.nvim_buf_get_name(timesheet_buffer)

    -- Validate: Parse Lua content
    local chunk, parse_err = load(lua_content, "timesheet", "t")
    if not chunk then
      vim.notify("epoch: cannot save timesheet - lua syntax error: " .. tostring(parse_err), vim.log.levels.ERROR)
      -- Don't close the window - return early
      return
    end

    -- Execute the chunk to get the timesheet table
    local success, timesheet = pcall(chunk)
    if not success then
      vim.notify("epoch: cannot save timesheet - execution error: " .. tostring(timesheet), vim.log.levels.ERROR)
      return
    end

    -- Check if timesheet is a table
    if type(timesheet) ~= "table" then
      vim.notify("epoch: cannot save timesheet - invalid timesheet format (not a table)", vim.log.levels.ERROR)
      return
    end

    -- Validate timesheet structure
    local valid, msg = storage.validate_timesheet(timesheet)
    if not valid then
      vim.notify("epoch: validation error - " .. msg, vim.log.levels.ERROR)
      return
    end

    -- Check for overlapping intervals
    local overlap, overlap_msg = storage.check_overlapping_intervals(timesheet.intervals, timesheet.date)
    if overlap then
      vim.notify("epoch: validation error - " .. overlap_msg, vim.log.levels.ERROR)
      return
    end

    -- If we got here, the timesheet is valid - save it
    vim.fn.writefile(lines, timesheet_path)
    vim.notify("epoch: timesheet saved", vim.log.levels.INFO)
  end

  -- Now close the window and clean up the buffer
  if is_window_open() then
    vim.api.nvim_win_close(timesheet_window, true)
    timesheet_window = nil
  end

  if timesheet_buffer ~= nil and vim.api.nvim_buf_is_valid(timesheet_buffer) then
    vim.api.nvim_buf_delete(timesheet_buffer, { force = true })
    timesheet_buffer = nil
  end
end

-- Convert any Lua table to lines for display
local function format_table_for_display(data)
  -- Use the get_lua_table function from storage
  local lua_content = storage.get_lua_table(data)
  local lines = {}
  
  for line in lua_content:gmatch("([^\r\n]+)") do
    table.insert(lines, line)
  end
  
  return lines
end

-- Format a timesheet for display
local function format_timesheet(timesheet)
  return format_table_for_display(timesheet)
end

-- open the timesheet window
function ui.open_timesheet()

  -- get the timesheet path for today
  local timesheet_path = storage.get_timesheet_path()

  -- create the timesheet file if it doesn't exist
  if vim.fn.filereadable(timesheet_path) == 0 then
    -- Create a default timesheet structure
    local timesheet = storage.create_default_timesheet()
    storage.save_timesheet(timesheet)
  else
    -- Re-save the file to ensure consistent formatting
    local timesheet = storage.load_timesheet()
    storage.save_timesheet(timesheet)
  end

  -- create a new buffer for the file
  timesheet_buffer = vim.api.nvim_create_buf(false, false)  -- not listed, normal (not scratch)
  vim.api.nvim_buf_set_option(timesheet_buffer, 'bufhidden', 'hide')

  -- set the buffer name and load file content directly
  vim.api.nvim_buf_set_name(timesheet_buffer, timesheet_path)

  -- read the file content directly
  local content = vim.fn.readfile(timesheet_path)
  vim.api.nvim_buf_set_lines(timesheet_buffer, 0, -1, false, content)

  -- set buffer options
  vim.api.nvim_buf_set_option(timesheet_buffer, 'filetype', 'lua')
  vim.api.nvim_buf_set_option(timesheet_buffer, 'swapfile', false)
  vim.api.nvim_buf_set_option(timesheet_buffer, 'modifiable', true)

  -- Add an autocmd for the 'w' save command to validate
  vim.api.nvim_create_autocmd({"BufWriteCmd"}, {
    buffer = timesheet_buffer,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(timesheet_buffer, 0, -1, false)
      local content = table.concat(lines, "\n")
      local path = vim.api.nvim_buf_get_name(timesheet_buffer)

      -- Validate the timesheet content (similar to close_window validation)
      local chunk, err = load(content, "timesheet", "t")
      if not chunk then
        vim.notify("epoch: cannot save timesheet - lua syntax error: " .. tostring(err), vim.log.levels.ERROR)
        return
      end

      local success, timesheet = pcall(chunk)
      if not success then
        vim.notify("epoch: cannot save timesheet - execution error: " .. tostring(timesheet), vim.log.levels.ERROR)
        return
      end

      if type(timesheet) ~= "table" then
        vim.notify("epoch: cannot save timesheet - invalid timesheet format (not a table)", vim.log.levels.ERROR)
        return
      end

      local valid, msg = storage.validate_timesheet(timesheet)
      if not valid then
        vim.notify("epoch: validation error - " .. msg, vim.log.levels.ERROR)
        return
      end

      local overlap, overlap_msg = storage.check_overlapping_intervals(timesheet.intervals, timesheet.date)
      if overlap then
        vim.notify("epoch: validation error - " .. overlap_msg, vim.log.levels.ERROR)
        return
      end

      -- If all validations pass, save the file
      vim.fn.writefile(lines, path)
      vim.api.nvim_buf_set_option(timesheet_buffer, 'modified', false)
      vim.notify("epoch: timesheet saved", vim.log.levels.INFO)
    end
  })

  -- calculate window dimensions based on percentage of Neovim window size
  -- Use half the width of what trap does, as timesheet files are long but narrow
  local width = math.floor(vim.o.columns * 0.4)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create a direct floating window with fixed size
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = "epoch - timesheet",
    title_pos = "center",
  }
  
  timesheet_window = vim.api.nvim_open_win(timesheet_buffer, true, win_opts)
  
  -- Set window options for proper display
  vim.api.nvim_win_set_option(timesheet_window, 'wrap', false)
  vim.api.nvim_win_set_option(timesheet_window, 'scrolloff', 2)
  vim.api.nvim_win_set_option(timesheet_window, 'sidescrolloff', 5)
  vim.api.nvim_win_set_option(timesheet_window, 'cursorline', true)
  vim.api.nvim_win_set_option(timesheet_window, 'winhighlight', 'Normal:EpochNormal,FloatBorder:EpochBorder,FloatTitle:EpochTitle')

  -- set window-local keymaps
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(timesheet_buffer, 'n', 'q', ':lua require("epoch").edit()<CR>', opts)
  vim.api.nvim_buf_set_keymap(timesheet_buffer, 'n', '<Esc>', ':lua require("epoch").edit()<CR>', opts)
  vim.api.nvim_buf_set_keymap(timesheet_buffer, 'n', 'w', ':w<CR>', opts)
end

-- toggle the timesheet window
function ui.toggle_timesheet()

  -- First check if a window is already open
  if is_window_open() then
    -- If so, try to close it (with validation)
    close_window()
  else
    -- Check the path and open the timesheet
    local path = storage.get_timesheet_path()
    local file_exists = vim.fn.filereadable(path) == 1

    -- If the timesheet doesn't exist, prompt to create first interval
    if not file_exists then
      require('epoch.timeops').add_interval()
    else
      ui.open_timesheet()
    end
  end
end

-- Format the weekly report for display
local function format_weekly_report(report)
  return format_table_for_display(report)
end

-- toggle the weekly report window
function ui.toggle_report()
  if is_window_open() then
    close_window()
  else
    show_report()
  end
end

-- show the weekly report
local function show_report()
  -- create a non-file buffer for the report
  timesheet_buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(timesheet_buffer, 'bufhidden', 'wipe')

  -- get weekly report
  local report = timeops.get_weekly_report()

  -- format report data
  local lines = format_weekly_report(report)

  -- update buffer content
  vim.api.nvim_buf_set_lines(timesheet_buffer, 0, -1, false, lines)

  -- keep the report readonly since it's a summary
  vim.api.nvim_buf_set_option(timesheet_buffer, 'modifiable', false)
  vim.api.nvim_buf_set_option(timesheet_buffer, 'filetype', 'lua')
  vim.api.nvim_buf_set_option(timesheet_buffer, 'readonly', true)

  -- calculate window dimensions based on percentage of Neovim window size
  -- Use half the width of what trap does, as timesheet files are long but narrow
  local width = math.floor(vim.o.columns * 0.4)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create a direct floating window with fixed size
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = "epoch - weekly report",
    title_pos = "center",
  }
  
  timesheet_window = vim.api.nvim_open_win(timesheet_buffer, true, win_opts)
  
  -- Set window options for proper display
  vim.api.nvim_win_set_option(timesheet_window, 'wrap', false)
  vim.api.nvim_win_set_option(timesheet_window, 'scrolloff', 2)
  vim.api.nvim_win_set_option(timesheet_window, 'sidescrolloff', 5)
  vim.api.nvim_win_set_option(timesheet_window, 'cursorline', true)
  vim.api.nvim_win_set_option(timesheet_window, 'winhighlight', 'Normal:EpochNormal,FloatBorder:EpochBorder,FloatTitle:EpochTitle')

  -- set window-local keymaps
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(timesheet_buffer, 'n', 'q', ':lua require("epoch").show_report()<CR>', opts)
  vim.api.nvim_buf_set_keymap(timesheet_buffer, 'n', '<Esc>', ':lua require("epoch").show_report()<CR>', opts)
end

-- setup function that gets called on initialization
function ui.setup()
  -- reset highlights to match current theme
  setup_highlights()
  
  -- set up autocmd to refresh highlights when colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      setup_highlights()
    end,
    group = vim.api.nvim_create_augroup("EpochHighlightRefresh", { clear = true }),
  })
end

return ui