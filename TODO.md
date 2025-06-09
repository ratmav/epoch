# TODO

## 1. Standards

### Current Task: Fix 22 Linting Warnings
- [x] Run initial workflow iteration to assess current state
- [x] Identify and document all 22 linting warnings
- [x] Fix linting warnings systematically (22 → 14 warnings remaining)
- [x] Run full workflow loop after each fix to prevent regressions

**Progress: 8/22 warnings fixed**
- ✅ Fixed: workflow.lua shadowing upvalue 
- ✅ Fixed: laconic.lua func_name overwrite (refactored to functional approach)
- ✅ Fixed: laconic.lua 8 unused loop variables (used string.gsub counting)
- ✅ Fixed: laconic.lua global printf (removed unnecessary C-ism)

**22 Linting Warnings Found:**
1. `lua/epoch/ui/logic/workflow.lua:76:9` - shadowing upvalue 'timesheet_logic'
2. `scripts/laconic.lua:99:15` - value assigned to variable 'func_name' is overwritten before use
3. `scripts/laconic.lua:137:25` - unused loop variable 'word'
4. `scripts/laconic.lua:140:25` - unused loop variable 'word'
5. `scripts/laconic.lua:143:25` - unused loop variable 'word'
6. `scripts/laconic.lua:146:25` - unused loop variable 'word'
7. `scripts/laconic.lua:149:25` - unused loop variable 'word'
8. `scripts/laconic.lua:152:25` - unused loop variable 'word'
9. `scripts/laconic.lua:160:25` - unused loop variable 'word'
10. `scripts/laconic.lua:163:25` - unused loop variable 'word'
11. `scripts/laconic.lua:315:10` - setting non-standard global variable 'printf'
12. `tests/report/generator/processor/week_spec.lua:26:7` - loop is executed at most once
13. `tests/storage/serializer/array_serializer_spec.lua:13:121` - line too long (134 > 120)
14. `tests/storage/serializer/array_serializer_spec.lua:26:121` - line too long (133 > 120)
15. `tests/storage/serializer/array_serializer_spec.lua:36:121` - line too long (133 > 120)
16. `tests/storage/serializer/table_serializer_spec.lua:13:121` - line too long (124 > 120)
17. `tests/storage/serializer/table_serializer_spec.lua:33:121` - line too long (125 > 120)
18. `tests/storage/serializer/table_serializer_spec.lua:45:121` - line too long (123 > 120)
19. `tests/storage/serializer/table_serializer_spec.lua:56:121` - line too long (130 > 120)
20. `tests/ui/logic_spec.lua:90:121` - line too long (121 > 120)
21. `tests/ui_logic_spec.lua:53:7` - setting read-only field 'time' of global 'os'
22. `tests/ui_logic_spec.lua:58:7` - setting read-only field 'time' of global 'os'

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
