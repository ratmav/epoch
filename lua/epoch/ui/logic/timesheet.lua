-- epoch/ui/logic/timesheet.lua
-- Timesheet validation and manipulation logic

local validation = require('epoch.validation')

local timesheet_logic = {}

-- Parse Lua content safely
local function parse_lua_content(content)
  local chunk, err = loadstring(content, "timesheet")
  if not chunk then
    return nil, "lua syntax error: " .. tostring(err)
  end

  local ok, timesheet_data = pcall(chunk)
  if not ok then
    return nil, "execution error: " .. tostring(timesheet_data)
  end

  return timesheet_data, nil
end

-- Validate parsed timesheet data
local function validate_parsed_data(timesheet_data)
  if type(timesheet_data) ~= "table" then
    return nil, "invalid timesheet format (not a table)"
  end

  local valid, validation_err = validation.validate_timesheet(timesheet_data)
  if not valid then
    return nil, validation_err
  end

  return timesheet_data, nil
end

-- Validate timesheet content
function timesheet_logic.validate_content(content)
  local timesheet_data, parse_err = parse_lua_content(content)
  if not timesheet_data then
    return nil, parse_err
  end

  return validate_parsed_data(timesheet_data)
end

-- Update daily total in a timesheet
function timesheet_logic.update_daily_total(timesheet_data, calculate_fn)
  local updated = vim.deepcopy(timesheet_data)
  updated.daily_total = calculate_fn(updated)
  return updated
end

-- Ensure timesheet file exists, create if needed
function timesheet_logic.ensure_timesheet_exists(timesheet_path, storage, date)
  if vim.fn.filereadable(timesheet_path) == 0 then
    local timesheet_data = storage.create_default_timesheet(date)
    storage.save_timesheet(timesheet_data)
  end
end

-- Load timesheet content from file
function timesheet_logic.load_timesheet_content(timesheet_path)
  return table.concat(vim.fn.readfile(timesheet_path), '\n')
end

return timesheet_logic