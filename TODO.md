# TODO

## Notes on Dependencies


## Next Immediate Task 🚨

- Laconic refactoring
  - Move more business logic from ui.lua to ui_logic.lua
  - Ensure ui.lua focuses only on presentation and UI interactions
  - Review all files to ensure they meet the < 150 lines guideline
  - Review all functions to ensure they meet the < 15 lines guideline
  - review all code against the coding standards listed below.
- Update documentation for new implementation
  - plenary.nvim is required for:
    - Testing framework (used by minimal_init.lua for test execution)
- github action to lint, check formatting, and test new pull requests.


## Original Coding Standards

* Functional programming style preferred
    * under 3 lines of code mean a function may be overkill
        * investigate list comprehensions and lambdas.
    * under 5 lines is a good sign.
    * 5-10 lines ok OK.
    * 10-15 lines is a warning sign.
    * over 15 lines is a no-go.
    * functions should be logically grouped into single-file modules.
        * under 100 lines of code is a good sign.
        * 100 lines of code is a warning sign.
        * over 150 lines of code is a no-go.
    * classes are ok to use, but only if:
        * we need to maintain more than a few variable's worth of state
        * we need to tie state to data, so we can have cleaner syntax for things like `car.turn()`
        * each class is stored it's own file
            * only one class per file
            * the filename is the class name in snake case.
        * you observe the single responsibility principle for any classes.
        * you observe the principle of least suprise for any design decisions.
        * you favor composition over inheritance for your class design.
            * this does not necessarily mean a functional approach, although that is appreciated
            * if we have state or want to have some kind of inhertance to keep code dry, then
              you are required to use a composition-based class approach.
        * you do not write classes that are longer than 150 lines of actual code.
            * under 100 lines of code is a good sign.
            * 100 lines of code is a warning sign.
            * over 150 lines of code is a no-go.
* you use meaningful english words for function names, class names, variable names, etc. these types tell a story.
* you do not add any features or capabilities without my explicit instruction to do so.
    * less is more.
* When it comes to naming conventions, specific names, etc. we need to be very consistent with the terminolgy used in the documentation directory.
* Follow the "zeroing in" naming pattern where filenames and class names move from general to specific as you read left to right (e.g., domain_component_specific_entity.py).
* abstractions emerge, i.e. wait for us to actually repeat ourselves or for patterns to present themselves in the code before we attempt to write abstractions to handle more general use cases. this will help us fend off speculative generality, which is just another form of premature optimization, which is the root of all evil.
* for our tests, we strongly prefer fixtures and functional
    * we prefex to exercise the code against actual data
    * avoid mocking unless a fixture won't do the job
* when debugging, you do not add print statements or extra logging to the code.
* when debugging, you never ever guess or hack around a problem, you detect the root cause and solve the root cause.

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
