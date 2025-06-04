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
- Complete manual test plan execution (tests/MANUAL_TEST_PLAN.md)
  - Execute all test groups and document results
  - Verify clean toggle behavior and user experience
- Update documentation, including README for developer and the plugin .txt documentation
- GitHub action to lint, check formatting, and test new pull requests

## post v0.1.0 New features

- add support for :EpochEdit <date/> to open the timesheet for a specific date
  - no date opens today's timesheet by default

