# TODO

## 1. Standards

### Current Task: ✅ COMPLETED - All Linting Warnings Fixed
- [x] Run initial workflow iteration to assess current state
- [x] Identify and document all 22 linting warnings
- [x] Fix linting warnings systematically (22 → 0 warnings remaining)
- [x] Run full workflow loop after each fix to prevent regressions

**Progress: 22/22 warnings fixed (100% complete)**
- ✅ Fixed: workflow.lua shadowing upvalue 
- ✅ Fixed: laconic.lua func_name overwrite (refactored to functional approach)
- ✅ Fixed: laconic.lua 8 unused loop variables (used string.gsub counting)
- ✅ Fixed: laconic.lua global printf (removed unnecessary C-ism)
- ✅ Fixed: array_serializer_spec.lua 3 line length violations
- ✅ Fixed: week_spec.lua loop executed at most once (replaced with next())
- ✅ Fixed: table_serializer_spec.lua 4 line length violations (multiline formatting)
- ✅ Fixed: ui/logic_spec.lua line too long (multiline formatting)
- ✅ Fixed: ui_logic_spec.lua read-only os.time assignments (use fixed timestamps)

**Current Status: 🎉 ALL CLEAN**
- ✅ `make test`: All tests pass (240+ tests, 0 failures)
- ✅ `make coverage`: 100% test coverage
- ✅ `make laconic`: All files <150 lines, all functions <15 lines  
- ✅ `make lint`: 0 warnings, 0 errors

Maintain discipline w.r.t. coding standards in CLAUDE.md at all times.

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
