# Test Fixtures Documentation

This directory contains all test fixture data for the Epoch plugin test suite. Fixtures are organized by domain and stored at the lowest level they are used to maximize reusability and maintainability.

## Organization Principle

Fixtures follow the principle of being stored at the **lowest common denominator** in the directory tree:
- If a fixture is used by only one spec, it lives in the same fixture file as related fixtures
- If a fixture is used by multiple specs in the same module, it's stored at the module level
- If a fixture is used across multiple modules, it's stored at the shared level

## Fixture Files

### `init.lua`
- Main fixture registry that loads and provides access to all fixture data
- Provides the global `fixtures.get(path)` function used throughout tests
- Prevents fixture mutation through deep copying

### `interval_fixtures.lua`
- **Domain**: Time tracking intervals
- **Usage**: Used across validation, UI, and report modules
- **Structure**:
  - `valid.*` - Well-formed intervals for happy path testing
  - `invalid.*` - Malformed intervals for validation testing
  - `examples.*` - Real-world interval examples
  - `serializer.*` - Specialized data for serializer testing

### `timesheet_fixtures.lua`
- **Domain**: Daily timesheet structures
- **Usage**: Used across storage, validation, and UI modules
- **Structure**:
  - `valid.*` - Well-formed timesheets with various configurations
  - `invalid.*` - Malformed timesheets for validation testing
  - `storage.*` - Specialized data for storage testing

### `time_fixtures.lua`
- **Domain**: Time-related data (parsing, validation, formatting)
- **Usage**: Used across time_utils and validation modules
- **Structure**:
  - `validation.*` - Time format validation test data
  - `format_timestamps.*` - Timestamp formatting test data
  - `parsing.*` - Time parsing test data
  - `dates.*` - Common date arrays used across multiple test files

### `report_fixtures.lua`
- **Domain**: Report generation and formatting
- **Usage**: Used exclusively by report module (18+ test files)
- **Structure**:
  - `input.*` - Input timesheet data for report generation
  - `expected_structure.*` - Expected report output structures
  - `test_*` - Specialized test data for different report components
  - `*_data.*` - Test data organized by report component (generator, formatter, etc.)

### `ui_fixtures.lua`
- **Domain**: User interface components
- **Usage**: Used by UI module tests
- **Structure**:
  - Mock data for UI component testing
  - Window configuration test data

## Fixture Access Pattern

All test files use the global `fixtures` object to access test data:

```lua
describe("my module", function()
  it("should do something", function()
    local test_data = fixtures.get('intervals.valid.frontend')
    -- test logic here
  end)
end)
```

## Fixture Path Convention

Fixture paths follow a dot-notation hierarchy:
- `domain.category.specific_item`
- Examples:
  - `intervals.valid.frontend`
  - `timesheets.invalid.missing_date`
  - `time.dates.storage_test_dates`
  - `reports.generator_timesheets.basic_with_dev_interval`

## Benefits of This Organization

1. **No Inline Fixtures**: All test data is externalized and reusable
2. **Consistent Access**: Single global `fixtures.get()` interface
3. **Mutation Protection**: Fixtures are deep-copied to prevent test interference
4. **Maintainability**: Changes to test data are centralized
5. **Discoverability**: Clear organization makes finding relevant fixtures easy
6. **Reusability**: Fixtures can be shared across multiple test files

## Fixture Elimination Status

✅ **Phase 0-5**: All inline fixtures extracted from 35+ test files
✅ **Phase 6**: Verified no problematic inline fixtures remain
- Factory tests retain acceptable inline data for testing parameterized construction
- All shared data structures extracted to appropriate fixture files
- Common date arrays consolidated in `time_fixtures.lua`

## Migration Notes

During the fixture elimination initiative:
- Extracted 500+ lines of inline test data
- Created comprehensive fixture coverage for all domains
- Maintained 100% test coverage throughout migration
- Fixed test isolation issues and improved test reliability