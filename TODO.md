# TODO

## 1. Standards

- Fix remaining 22 linting warnings. Maintain discipline w.r.t. coding standards in CLAUDE.md at all times.

## 2. User Experience & Documentation

- Confirm we use the day's existing timesheet, don't create new ones without confirmation dialog
- Complete manual test plan execution (tests/MANUAL_TEST_PLAN.md)
  - Execute all test groups and document results
  - Verify clean toggle behavior and user experience
- Update documentation, including README and plugin .txt documentation
- GitHub action to lint, check formatting, and test new pull requests

## 3. New Features

- Add support for :EpochEdit <date/> to open the timesheet for a specific date
  - No date opens today's timesheet by default

## 4. Infrastructure

- Change 'NVIM_INSTALL_MODE' to 'NVIM_HEADLESS_MODE' in dotfiles for better semantics
