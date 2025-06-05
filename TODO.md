# TODO

## 1. Testing

- Create tests for config.lua, commands.lua, and ui/interval.lua which have testable logic

## 2. User Experience & Documentation

- Confirm we use the day's existing timesheet, don't create new ones without confirmation dialog
- Complete manual test plan execution (tests/MANUAL_TEST_PLAN.md)
  - Execute all test groups and document results
  - Verify clean toggle behavior and user experience
- Update documentation, including README and plugin .txt documentation
- GitHub action to lint, check formatting, and test new pull requests

## 4. Future Features (post v0.1.0)

- Add support for :EpochEdit <date/> to open the timesheet for a specific date
  - No date opens today's timesheet by default