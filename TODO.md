# TODO

## 1. Architecture Consistency

### init.lua Pattern Enforcement
- **All init.lua files should only manage registry/delegation, not implement logic**
- Review all existing init.lua files to ensure they only contain `require()` and delegation
- Move any logic from init.lua files to appropriate focused modules
- Ensure consistent pattern: foo/init.lua (not foo.lua + foo/ directory)

### File Structure Standards
- No foo.lua file that acts like an init.lua alongside a foo/ directory
- Should be foo/init.lua that only delegates
- Review files ignored from testing to confirm they are ONLY init.lua files

## 2. Code Quality & Standards

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

## 3. User Experience & Documentation
- Confirm we use the day's existing timesheet, don't create new ones without confirmation dialog
- Complete manual test plan execution (tests/MANUAL_TEST_PLAN.md)
  - Execute all test groups and document results
  - Verify clean toggle behavior and user experience
- Update documentation, including README and plugin .txt documentation
- GitHub action to lint, check formatting, and test new pull requests

## 4. Future Features (post v0.1.0)

- Add support for :EpochEdit <date/> to open the timesheet for a specific date
  - No date opens today's timesheet by default