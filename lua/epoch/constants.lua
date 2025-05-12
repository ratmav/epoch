-- epoch/constants.lua
-- Shared constants for dates, times, and patterns
-- coverage: no tests

local constants = {}

-- Date patterns for timesheet filenames and validation
constants.TIMESHEET_DATE_PATTERN = "%d%d%d%d%-%d%d%-%d%d"
constants.TIMESHEET_DATE_PATTERN_ANCHORED = "^%d%d%d%d%-%d%d%-%d%d$"
constants.TIMESHEET_DATE_PATTERN_WITH_CAPTURE = "^(%d%d%d%d%-%d%d%-%d%d)$"
constants.TIMESHEET_FILENAME_PATTERN = "^%d%d%d%d%-%d%d%-%d%d%.lua$"

-- Time patterns for 12-hour format validation and parsing
constants.TIME_12_HOUR_PATTERN = "(%d+):(%d+)%s+([AP]M)"
constants.TIME_12_HOUR_VALIDATION_PATTERN = "^%d+:%d+%s+[AP]M$"

return constants