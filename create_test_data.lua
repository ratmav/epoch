-- Create test data for manual testing
local storage_path = arg[1] or (vim and vim.fn.stdpath('data') or os.getenv('HOME') .. '/.local/share/nvim')
local data_dir = storage_path .. '/epoch'

-- Function to write a Lua table to a file
local function write_table_to_file(file_path, tbl)
  local file = io.open(file_path, "w")
  if not file then
    print("Failed to open file: " .. file_path)
    return false
  end
  
  -- Simple function to serialize a table
  local function serialize(val, indent)
    indent = indent or 0
    local spaces = string.rep("  ", indent)
    
    if type(val) == "table" then
      local result = "{\n"
      for k, v in pairs(val) do
        local key_str
        if type(k) == "string" then
          key_str = '["' .. k .. '"] = '
        else
          key_str = "[" .. tostring(k) .. "] = "
        end
        
        result = result .. spaces .. "  " .. key_str .. serialize(v, indent + 1) .. ",\n"
      end
      result = result .. spaces .. "}"
      return result
    elseif type(val) == "string" then
      return '"' .. val .. '"'
    else
      return tostring(val)
    end
  end
  
  file:write("return " .. serialize(tbl))
  file:close()
  return true
end

-- Create the data directory if it doesn't exist
os.execute('mkdir -p ' .. data_dir)

print("Creating test timesheets in: " .. data_dir)

-- Create several test timesheets for different dates
local test_data = {
  -- Last month
  ["2025-04-15"] = {
    date = "2025-04-15",
    daily_total = "05:30",
    intervals = {
      {
        client = "acme-corp",
        project = "website-redesign",
        task = "frontend-planning",
        start = "09:00 AM",
        stop = "10:30 AM",
      },
      {
        client = "acme-corp",
        project = "website-redesign",
        task = "backend-planning",
        start = "11:00 AM",
        stop = "01:00 PM",
      },
      {
        client = "client-x",
        project = "mobile-app",
        task = "design-review",
        start = "02:00 PM",
        stop = "04:00 PM",
      }
    }
  },
  
  -- Last week
  ["2025-05-06"] = {
    date = "2025-05-06",
    daily_total = "06:45",
    intervals = {
      {
        client = "client-x",
        project = "mobile-app",
        task = "development",
        start = "08:30 AM",
        stop = "12:15 PM",
      },
      {
        client = "client-y",
        project = "api-service",
        task = "documentation",
        start = "01:30 PM",
        stop = "04:30 PM",
      }
    }
  },
  
  -- Yesterday
  ["2025-05-22"] = {
    date = "2025-05-22",
    daily_total = "07:15",
    intervals = {
      {
        client = "acme-corp",
        project = "website-redesign", 
        task = "coding",
        start = "09:00 AM",
        stop = "11:45 AM",
      },
      {
        client = "client-z",
        project = "security-audit",
        task = "testing",
        start = "01:00 PM",
        stop = "03:30 PM",
      },
      {
        client = "personal",
        project = "admin",
        task = "emails",
        start = "04:00 PM",
        stop = "06:00 PM",
      }
    }
  },
  
  -- Today
  ["2025-05-23"] = {
    date = "2025-05-23",
    daily_total = "04:30",
    intervals = {
      {
        client = "client-y",
        project = "api-service",
        task = "debugging",
        start = "10:00 AM",
        stop = "12:30 PM",
      },
      {
        client = "acme-corp",
        project = "website-redesign",
        task = "deployment",
        start = "02:00 PM",
        stop = "04:00 PM",
      }
    }
  }
}

-- Write each timesheet to a file
local count = 0
for date, timesheet in pairs(test_data) do
  local file_path = data_dir .. "/" .. date .. ".lua"
  if write_table_to_file(file_path, timesheet) then
    print("Created timesheet: " .. file_path)
    count = count + 1
  end
end

print("Done! Created " .. count .. " test timesheets")
print("Run :EpochReport to see the report")
print("Use :EpochClear or 'make clean' to clean up the test data when done")