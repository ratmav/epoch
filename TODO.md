# TODO

## 1. Refactor to meet coding standards

1. `make test` must pass
2. `make coverage` must pass
    - no `make test` regressions
3. `make laconic` must pass
    - no `make test` regressions
    - no `make coverage` regressions
4. `make lint` must pass
    - no `make test` regressions
    - no `make coverage` regressions
    - no `make laconic` regressions

### Refactoring Guidelines

* IMPORTANT: BREAK THE REFACTOR INTO SMALL, LOGICAL CHUNKS
    * REFACTOR ONE THING AT A TIME
    * LEAVE ORIGINAL IMPLEMENTATION IN PLACE DURING REFACTOR
    * REPLACE ORIGINAL IMPLEMENTATION WITH REFACTOR, I.E. REPOINT CALLERS AT REFACTORED CODE
    * ONCE REFACTORED CODE HAS COMPLETELY REPLACED ORIGINAL IMPLEMENTATION, REMOVE ORIGINAL IMPLEMENTATION AFTER CONFIRMGING THAT ORIGINAL IMPLEMENTATION IS DEAD CODE
* FOLLOW THE CODING STANDARDS BELOW
* LEVERAGE THE EXISTING TEST SUITE
* OUR TEST FIXTURES SHOULD NOT CHANGE, BUT MAY NEED TO BE MOVED TO ALIGN WITH UPDATES TO THE PROJECT STRUCTURE
* DO NOT ENCODE METADATA IN FILENAMES, I.E `report_calculations.lua`. USE THE PROJECT FILESYTEM STRUCTURE FOR THIS, I.E `report/calculate.lua`

## Post Standards Refactoring
- no logic in init.lua, only delegation to modules
- no foo.lua (which acts like an init.lua), the a foo directory
    - should be foo/init.lua
    - init.lua only delegates
- review files ignored from testing to confirm they are ONLY init.lua files
- confirm that we use the day's existing timesheet, we don't create new ones (and lose existing) without a confirmation dialog
- Complete manual test plan execution (MANUAL_TEST_PLAN.md)
  - Test all 24 test cases across 11 test groups
  - Verify clean toggle behavior and user experience
- Update documentation, including README for developer and the plugin .txt documentation
- GitHub action to lint, check formatting, and test new pull requests

## post v0.1.0 New features

- add support for :EpochEdit <date/> to open the timesheet for a specific date
  - no date opens today's timesheet by default

**Final Steps:**

## Testing

### Test Plan for Epoch Plugin

#### Overview
Epoch is a lightweight time tracking plugin for Neovim. This test plan covers all major functionalities to ensure reliable operation.

#### Environment Setup
- Neovim (latest stable version)
- Clean installation of the plugin
- Test directory with sample timesheets

#### Functionality Tests

##### 1. Basic Operations

###### 1.1. Installation & Initialization
- Verify plugin loads correctly on Neovim startup
- Verify no error messages during initialization
- Confirm all commands are registered correctly

###### 1.2. Command Registration
- Verify `:EpochEdit` command is available
- Verify `:EpochInterval` command is available
- Verify `:EpochReport` command is available
- Verify `:EpochClear` command is available

##### 2. Timesheet Management

###### 2.1. Creating Timesheet
- Execute `:EpochEdit` on a day with no timesheet
- Verify it prompts for first interval creation
- Add client/project/task information
- Verify timesheet is created with correct structure
- Verify timesheet includes the created interval

###### 2.2. Opening Existing Timesheet
- Execute `:EpochEdit` on a day with existing timesheet
- Verify timesheet opens in floating window
- Verify correct formatting of timesheet content
- Verify intervals are displayed in chronological order

###### 2.3. Window Management
- Verify window displays with correct dimensions (40% width, 80% height)
- Verify scrolling works for long timesheets
- Verify keymaps work (`q`, `Esc`, `w`)
- Verify window closes correctly with `q` or `Esc`

##### 3. Interval Management

###### 3.1. Adding Intervals
- Execute `:EpochInterval` command
- Complete client/project/task prompts
- Verify new interval is added with correct start time
- Verify daily total is updated correctly

###### 3.2. Auto-closing Intervals
- Add a new interval when previous interval has no end time
- Verify previous interval is auto-closed
- Verify appropriate spacing between intervals (minimum 1 minute)

###### 3.3. Editing Intervals
- Manually edit an interval in the timesheet buffer
- Save with `:w`
- Verify changes persist

##### 4. Data Validation

###### 4.1. Time Format Validation
- Attempt to save with invalid time format (missing AM/PM, wrong format)
- Verify correct error message is shown
- Verify file is not saved
- Verify window remains open for correction

###### 4.2. Required Field Validation
- Attempt to save with missing required field (client, project, task)
- Verify correct error message is shown
- Verify file is not saved

###### 4.3. Overlap Detection
- Create two intervals with overlapping times
- Attempt to save
- Verify clear error message about which intervals overlap
- Verify file is not saved
- Fix overlap and save
- Verify file saves correctly

###### 4.4. Chronological Ordering
- Create intervals in non-chronological order
- Save the timesheet
- Reopen the timesheet
- Verify intervals are displayed in chronological order

##### 5. Weekly Reporting

###### 5.1. Report Generation
- Create timesheets for multiple days in a week
- Execute `:EpochReport` command
- Verify report correctly displays all days
- Verify correct calculation of time by client/project/task
- Verify grand total matches the sum of all intervals

###### 5.2. Report Display
- Verify report window opens with correct dimensions
- Verify read-only mode is enforced
- Verify window closes correctly

##### 6. Data File Management

###### 6.1. File Storage
- Create and modify timesheets
- Verify correct storage in the data directory
- Verify consistent file format
- Verify file naming convention (YYYY-MM-DD.lua)

###### 6.2. Data Cleanup
- Execute `:EpochClear` command
- Verify confirmation prompt appears
- Confirm cleanup
- Verify all timesheet files are deleted

#### Edge Cases & Error Handling

##### 7.1. Invalid Files
- Manually corrupt a timesheet file (invalid Lua syntax)
- Attempt to open the file
- Verify graceful error handling

##### 7.2. Concurrency
- Edit a timesheet in two Neovim instances simultaneously
- Verify changes in one instance don't cause errors in the other

##### 7.3. Large Timesheets
- Create a timesheet with 50+ intervals
- Verify performance remains acceptable
- Verify all functionality works with large datasets

##### 7.4. Time Boundaries
- Create intervals spanning midnight
- Verify correct handling of time calculations

#### User Experience

##### 8.1. Notifications
- Verify all error messages are clear and helpful
- Verify success messages display correctly
- Verify consistent lowercase style in notifications

##### 8.2. UI Consistency
- Verify consistent highlighting across theme changes
- Verify window borders and styling are consistent

#### Documentation Testing

##### 11.1. Help Documentation
- Verify all commands are documented correctly
- Verify examples match actual behavior
