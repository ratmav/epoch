-- epoch/storage/bulk_operations.lua
-- Bulk timesheet operations

local bulk_operations = {}
local discovery = require('epoch.storage.discovery')

-- Delete all timesheet files
function bulk_operations.delete_all_timesheets()
  local files = discovery.get_all_timesheet_files()
  local count = 0

  for _, file in ipairs(files) do
    if vim.fn.delete(file) == 0 then
      count = count + 1
    end
  end

  return count
end

return bulk_operations