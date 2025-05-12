local status = {}

local formatter = require('status.formatter')

status.determine_status = formatter.determine_status
status.exit_with_status = formatter.exit_with_status

return status