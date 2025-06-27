# MVC Refactor Target Structure

## Current Laconic Violations
- `models/report.lua` (227 lines) - needs to be split
- `models/timesheet.lua` (122 lines) - slightly over
- `services/time.lua` (123 lines) - slightly over
- 8 functions over 15 lines

## Target MVC Structure

### Models (Domain Objects)
- `models/timesheet.lua` - Single timesheet operations
  - `create()`, `add_interval()`, `close_current_interval()`
  - `calculate_total_minutes()` - sum intervals in THIS timesheet
  - `get_completed_intervals()` - query THIS timesheet's completed intervals
  - `validate()`
  - **Collection operations:**
    - `get_by_date_range(timesheets_array, start, end)` - query across multiple timesheets
    - `summary(timesheets_array)` - "summarize my timesheets" 
    - `group_by_week(timesheets_array)` - "group my timesheets by week"

- `models/interval.lua` - Single interval operations  
  - `create()`, `close()`, `is_open()`, `is_complete()`
  - `calculate_duration_minutes()` - for THIS interval
  - `validate()` ✅ ADDED

### Services (Utilities)
- `services/time.lua` - Generic date/time utilities
  - Time parsing/formatting (12-hour format)
  - Week number calculations (`get_week_number()`)
  - Date range utilities
  
- `services/storage.lua` - File persistence
  - Lua object serialization/deserialization
  - File I/O operations

### Controllers (Workflow Orchestration)
- `controllers/report.lua` - Report generation workflow
  - Orchestrates timesheet collection operations + time service
  - Builds report data structure for views

### Views (UI Presentation)
- `views/timesheet.lua` - Timesheet editing UI
- `views/report.lua` - Report display UI

## Migration Strategy
1. ✅ Add `interval.validate()` 
2. ✅ Fix long functions in models using safe/unsafe pattern
3. Add collection operations to timesheet model
4. Move report logic to controller
5. Run quality checks to ensure laconic compliance
6. Update existing tests to match new structure