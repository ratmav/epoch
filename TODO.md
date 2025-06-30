# MVC Refactor Target Structure

## Target MVC Structure

### Services (Utilities)
- `services/storage/*.lua` - File persistence
  - Lua object serialization/deserialization
  - File I/O operations

#### General for Storage Service
- use the existing `storage` as a guide, but not a definition or a requirement.
- ideally, this will be a bunch of `mv` commands and repointing module requirements statements
- test filesystem structure must match

### Views (formatting and presentation)
- `views/timesheet.lua` - Timesheet editing UI
    - this should be a modifiable buffer
- `views/report.lua` - Report display UI
    - this should be a read-only buffer

#### General for Views
- use the existing `ui` as a guide, but not a definition or a requirement.
- ideally, this will be a bunch of `mv` commands and repointing module requirements statements
    - the `ui` module has a separation of concerns problem. you might be better off rewriting it. remember we want a timesheet view and a report view that use the appropriate models and controllers that we  have, NOT any old ui code.
- test filesystem structure must match
