# TODO

## INLINE FIXTURE ELIMINATION PLAN

### Phase 0: Fix Current Test Failures (Base Case) - ✅ COMPLETE
- [x] Fix storage/serializer/table_serializer_spec.lua mixed keys test failure
- [x] Fix time_utils/parsing_spec.lua invalid date format test failure  
- [x] Run specific failing tests only to verify fixes

### Phase 1: Storage Serializer Module (4 files - DONE)
- [x] tests/storage/serializer/array_detection_spec.lua
- [x] tests/storage/serializer/value_formatter_spec.lua  
- [x] tests/storage/serializer/array_serializer_spec.lua
- [x] tests/storage/serializer/table_serializer_spec.lua (needs fix)

### Phase 2: Storage Core Module (3 files - Simple) - ✅ COMPLETE
- [x] tests/storage/serializer/interval_sorter_spec.lua - extracted timesheet inline fixtures  
- [x] tests/storage/discovery_spec.lua - extracted simple timesheet fixtures
- [x] BLOCKER FIXED: Individual test fixture loading (use global fixtures, not require)
- [x] tests/storage/bulk_operations_spec.lua - extracted simple timesheet fixtures
- [x] All individual tests passing

### Phase 3: Time Utils Module (3 files - Complex) - ✅ COMPLETE
- [x] tests/time_utils/validation_spec.lua - extracted hardcoded time strings
- [x] tests/time_utils/formatting_spec.lua - extracted timestamp values  
- [x] tests/time_utils/parsing_spec.lua - extracted date/time test data
- [x] Create comprehensive tests/fixtures/time_fixtures.lua
- [x] Run `make test` after each file

### Phase 4: Validation Module (2 files - Simple) - ✅ COMPLETE
- [x] tests/validation/fields/context_spec.lua (DONE)
- [x] tests/validation_modules_spec.lua - extracted remaining inline intervals
- [x] Run `make test` after completion

### Phase 5: Report Module (18 files - Most Complex)
- [x] tests/report/week_utils_spec.lua - extracted simple intervals
- [x] tests/report/generator/data_loader_spec.lua - extracted timesheet data
- [x] tests/report/generator/summary_utils_spec.lua - extracted summary dictionaries
- [x] tests/report/generator/processor/day_spec.lua - extracted complex timesheet structures
- [x] tests/report/generator/processor/week_spec.lua - extracted week data structures
- [x] tests/report/generator_spec.lua - extracted timesheet creation inline fixtures
- [x] tests/report/formatter/daily_spec.lua - extracted daily totals data
- [x] tests/report/formatter/table_spec.lua - extracted summary and row data
- [x] tests/report/formatter/week_spec.lua - extracted week data structures
- [ ] tests/report/formatter/overall_spec.lua - summary data
- [ ] tests/report/formatter/report_builder_spec.lua - report data structures
- [ ] tests/report/formatter/table/row_builder_spec.lua - summary data
- [ ] tests/report/formatter/table/column_calculator_spec.lua - table data
- [ ] tests/report/ui_spec.lua - mock data (special case)
- [ ] Extend tests/fixtures/report_fixtures.lua for all above
- [ ] Run `make test` after every 3-4 files

### Phase 6: Verification
- [ ] Run full `make check` to ensure 100% coverage maintained
- [ ] Verify NO inline fixtures remain in any test file
- [ ] Document fixture organization in tests/fixtures/README.md

### Phase 7: Performance

- [ ] Run each spec individually and confirm test runs complete in under 20 seconds

## 0. Fixtures AND Factories AND a Failing test

### The Strategy

Factories are perfect for:
- ✅ Valid data variations -
factory.build_report({total_minutes = 120})
- ✅ Happy path testing - consistent, well-formed structures
- ✅ Dynamic test data - different values per test run
- ✅ Default states - empty reports, new timesheets

Fixtures still make sense for:
- ✅ Failure cases - malformed data like {client = nil,
project = "test"}
- ✅ Complex scenarios - realistic multi-week reports with
specific patterns
- ✅ Edge cases - overlapping intervals, invalid time formats
- ✅ Regression data - capturing specific bugs found in
production
- ✅ Real-world examples - actual user data patterns

The best of both worlds:
-- Simple valid variations - use factory
local empty_report = factory.build_report()
local custom_report = factory.build_report({total_minutes = 300})

-- Complex/failure scenarios - use fixtures
local malformed_timesheet =
fixtures.get('timesheets.invalid.missing_date')
local overlapping_intervals =
fixtures.get('intervals.invalid.overlapping')

This way:
- Factories handle the "construction" of valid data
- Fixtures handle the "curation" of specific scenarios
- Registry still prevents mutation bugs
- Tests are more readable and maintainable

The factory validates our data contracts, while fixtures
capture real-world complexity. Perfect balance!

### The Objective

## 0. pass all checks

- we want 100% passing for all `make check` tests
    - we need to focus on our test coverage `make test` first
    - we need to make sure that a spec file is ***only*** testing the file with the matching name
    - we need to review all tests to confirm that we're always using fixtures defined in their own files, in the nested structure so that a given fixture is stored at the lowest level it can be (shared fixture is stored at level above two tests that use fixture, etc.)
    - then we can focus on laconic and linting
- some modules have an init.lua, some do not. we should always have an init.lua, not a foo.lua, then a foo directory (module)
    - init.lua should only delegate. if there is logic in init.lua, then that logic needs to be migrated to the appropriate module or broken out into a new module if it's a new responsiblity. we should also make sure that logic is tested
- the ui module has ui handling code that is often deliberately untested, but we also have logic that is testable. that logic should live in it's own ui/logic module (with an init, tests, etc.)

## 1. Refactoring for laconic compliance

- run `make check` to detect violations
- for each violation
    - refactor the violation
    - run `make check` to detect regresssions
        - for each regression
            - fix regression

## 2. Review for SRP violations
- confirm all files still observe the single responsiblity principle

## 3. Review refactored modular code for improved testability
  - Write additional functional tests for newly isolated modules
  - Test individual modules that are now independently testable
  - Focus on testing edge cases that were harder to test in monolithic modules
  - Verify test coverage is comprehensive across the modular architecture
- Apply coding standards throughout codebase

## Post-Refactoring
- add support for :EpochEdit <date/> to open the timesheet for a specific date
  - no date opens today's timesheet by default
- Complete manual test plan execution (MANUAL_TEST_PLAN.md)
  - Test all 24 test cases across 11 test groups
  - Verify clean toggle behavior and user experience
  - Ensure no regressions after architectural changes

**Final Steps:**
- Update documentation for new modular architecture
- GitHub action to lint, check formatting, and test new pull requests

## Refactoring Guidelines

* IMPORTANT: BREAK THE REFACTOR INTO SMALL, LOGICAL CHUNKS
    * REFACTOR ONE THING AT A TIME
    * LEAVE ORIGINAL IMPLEMENTATION IN PLACE DURING REFACTOR
    * REPLACE ORIGINAL IMPLEMENTATION WITH REFACTOR, I.E. REPOINT CALLERS AT REFACTORED CODE
    * ONCE REFACTORED CODE HAS COMPLETELY REPLACED ORIGINAL IMPLEMENTATION, REMOVE ORIGINAL IMPLEMENTATION AFTER CONFIRMGING THAT ORIGINAL IMPLEMENTATION IS DEAD CODE
* FOLLOW THE CODING STANDARDS BELOW
* LEVERAGE THE EXISTING TEST SUITE
* OUR TEST FIXTURES SHOULD NOT CHANGE, BUT MAY NEED TO BE MOVED TO ALIGN WITH UPDATES TO THE PROJECT STRUCTURE
* DO NOT ENCODE METADATA IN FILENAMES, I.E `report_calculations.lua`. USE THE PROJECT FILESYTEM STRUCTURE FOR THIS, I.E `report/calculate.lua`


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
