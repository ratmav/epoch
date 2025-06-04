# TODO

## 0. Refactor tooling scripts (coverage.lua, laconic.lua)

Both `scripts/coverage.lua` and `scripts/laconic.lua` have duplicate code and C-isms that need addressing:

**DRY Issues:**
- `get_lua_files()` function is identical in both scripts
- `printf(fmt, ...)` helper is identical in both scripts  
- Exit pattern `local exit_code = check_X(); os.exit(exit_code)` is duplicated
- Report formatting patterns (headers, status icons, summary sections) are similar

**Code Quality Issues:**
- `printf` is a C-ism, should use idiomatic Lua
- `printf` is defined after use, causing lint warnings about undefined variables

**Strategic Approach:**
Create `scripts/lib.lua` shared utility module with:
```lua
local lib = {}
function lib.get_lua_files() -- extract duplicate
function lib.print_formatted(fmt, ...) -- replace printf, better name
function lib.print_section_header(title, icon) -- template headers
function lib.determine_status(success, has_warnings) -- standardize status logic
function lib.exit_with_status(success) -- standardize exit pattern
return lib
```

**Implementation:**
1. Create `scripts/lib.lua` with extracted functions
2. For each script: copy to `.new` file, modify new file to use lib, compare outputs
3. Once outputs match: replace original with new version, remove `.new` file
4. Run full lint check to ensure issues resolved

**Testing Approach:**
- Write `scripts/lib.lua` with shared functions
- Copy `coverage.lua` → `coverage.new.lua`, modify to use lib
- Run both: `lua coverage.lua > old.txt` and `lua coverage.new.lua > new.txt`
- Compare: `diff old.txt new.txt` (should be identical)
- If identical: `rm coverage.lua && mv coverage.new.lua coverage.lua`
- Repeat for `laconic.lua`

**Future:** This prepares the tooling for potential extraction into separate package(s).

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

