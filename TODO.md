# TODO

## 1. Standards

### Current Task: Fix 8 Remaining Linting Warnings
- [x] Run initial workflow iteration to assess current state
- [x] Identify and document all 22 linting warnings
- [x] Fix linting warnings systematically (22 → 8 warnings remaining)
- [x] Run full workflow loop after each fix to prevent regressions

**Progress: 14/22 warnings fixed**
- ✅ Fixed: workflow.lua shadowing upvalue 
- ✅ Fixed: laconic.lua func_name overwrite (refactored to functional approach)
- ✅ Fixed: laconic.lua 8 unused loop variables (used string.gsub counting)
- ✅ Fixed: laconic.lua global printf (removed unnecessary C-ism)
- ✅ Fixed: array_serializer_spec.lua 3 line length violations
- ✅ Fixed: Additional issues from warnings 12-22

**8 Remaining Linting Warnings:**
1. `tests/report/generator/processor/week_spec.lua:26:7` - loop is executed at most once
2. `tests/storage/serializer/table_serializer_spec.lua:13:121` - line too long (124 > 120)
3. `tests/storage/serializer/table_serializer_spec.lua:33:121` - line too long (125 > 120)
4. `tests/storage/serializer/table_serializer_spec.lua:45:121` - line too long (123 > 120)
5. `tests/storage/serializer/table_serializer_spec.lua:56:121` - line too long (130 > 120)
6. `tests/ui/logic_spec.lua:90:121` - line too long (121 > 120)
7. `tests/ui_logic_spec.lua:53:7` - setting read-only field 'time' of global 'os'
8. `tests/ui_logic_spec.lua:58:7` - setting read-only field 'time' of global 'os'

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
