# Manual Test Plan for Epoch Time Tracking Plugin

## Test Environment Setup

**Prerequisites:**
- Neovim with plenary.nvim installed
- Epoch plugin loaded
- Fresh test environment (consider backing up existing `~/.local/share/nvim/epoch/` data)

---

## Test Group 1: Plugin Installation & Commands

### Test 1.1: Plugin Load
- [ ] Start Neovim
- [ ] Run `:lua print(vim.fn.exists(':EpochEdit'))`

**Expected:** Returns `2` (command exists)

### Test 1.2: Available Commands
- [ ] Type `:Epoch` and press Tab for completion

**Expected:** Shows all four commands: `EpochEdit`, `EpochInterval`, `EpochReport`, `EpochClear`

---

## Test Group 2: Basic Time Tracking

### Test 2.1: First Time Interval Creation
- [ ] Run `:EpochInterval`
- [ ] Enter client: `test-client`
- [ ] Enter project: `test-project` 
- [ ] Enter task: `test-task`

**Expected:**
- Prompts appear in sequence
- No error messages
- Confirmation that interval started

### Test 2.2: View Created Timesheet
- [ ] Run `:EpochEdit`

**Expected:**
- Floating window opens (40% width, 70% height)
- Shows today's date in YYYY-MM-DD format
- Contains one interval with current time as start
- Stop field is empty string `""`
- Lua syntax highlighting active

### Test 2.3: Manual Timesheet Editing
- [ ] In the edit window, change the task to `updated-task`
- [ ] Save with `:w`

**Expected:**
- No validation errors
- File saves successfully
- Window remains open

### Test 2.4: Close Edit Window
- [ ] Press `q` or `Esc`

**Expected:**
- Window closes
- File auto-saves

---

## Test Group 3: Multiple Intervals

### Test 3.1: Auto-Close Previous Interval
- [ ] Run `:EpochInterval` 
- [ ] Enter client: `client-two`
- [ ] Enter project: `project-two`
- [ ] Enter task: `task-two`
- [ ] Run `:EpochEdit`

**Expected:**
- First interval now has stop time filled in
- Second interval starts at the stop time of first interval
- Second interval has empty stop time

### Test 3.2: Manual Time Entry
- [ ] In edit window, manually set first interval:
  - start: `09:00 AM`
  - stop: `10:30 AM`
- [ ] Set second interval:
  - start: `10:30 AM` 
  - stop: `12:00 PM`
- [ ] Save with `:w`

**Expected:**
- No validation errors
- Daily total calculated as `03:00`

---

## Test Group 4: Time Format Validation

### Test 4.1: Valid Time Formats
- [ ] Test each format by editing intervals:
  - `12:00 AM` (midnight)
  - `01:30 AM` (early morning)
  - `12:00 PM` (noon)
  - `11:59 PM` (late night)
- [ ] Save after each edit

**Expected:** All formats accepted without error

### Test 4.2: Invalid Time Formats
- [ ] Try each invalid format:
  - `9:30` (missing AM/PM)
  - `09:30` (missing AM/PM)
  - `13:30 PM` (invalid hour)
  - `09:60 AM` (invalid minutes)
- [ ] Save after each attempt

**Expected:** Validation errors appear, file doesn't save

---

## Test Group 5: Interval Validation

### Test 5.1: Missing Required Fields
- [ ] Create interval with missing client field: `client = ""`
- [ ] Save

**Expected:** Validation error about required fields

### Test 5.2: Invalid Notes Format
- [ ] Change notes from `{}` to `"string"`
- [ ] Save

**Expected:** Validation error about notes format

### Test 5.3: Notes Array Validation
- [ ] Set notes to `{"valid note", "another note"}`
- [ ] Save

**Expected:** No errors, saves successfully

---

## Test Group 6: Overlap Detection

### Test 6.1: Overlapping Intervals
- [ ] Create two intervals:
  - Interval 1: `09:00 AM` to `11:00 AM`
  - Interval 2: `10:30 AM` to `12:00 PM`
- [ ] Save

**Expected:** Validation error about overlapping intervals

### Test 6.2: Adjacent Intervals (Valid)
- [ ] Create two intervals:
  - Interval 1: `09:00 AM` to `10:30 AM`
  - Interval 2: `10:30 AM` to `12:00 PM`
- [ ] Save

**Expected:** No errors, saves successfully

---

## Test Group 7: Reporting

### Test 7.1: Basic Report Generation
- [ ] Run `:EpochReport`

**Expected:**
- Floating window opens (50% width, 60% height)
- Shows current week data
- Sections: "By Day", "By Client", "Overall"
- Displays daily and client totals

### Test 7.2: Empty Report
- [ ] Delete all intervals from timesheet
- [ ] Save
- [ ] Run `:EpochReport`

**Expected:**
- Report shows appropriate "no data" messages
- No errors or crashes

---

## Test Group 8: Data Persistence

### Test 8.1: File Storage Location
- [ ] Create an interval
- [ ] Check file exists: `~/.local/share/nvim/epoch/YYYY-MM-DD.lua`

**Expected:** File exists and contains valid Lua table

### Test 8.2: Data Reload
- [ ] Close Neovim
- [ ] Restart Neovim  
- [ ] Run `:EpochEdit`

**Expected:** Previous data loads correctly

---

## Test Group 9: Edge Cases

### Test 9.1: Unclosed Interval Impact
- [ ] Create interval with stop time as `""`
- [ ] Save
- [ ] Run `:EpochReport`

**Expected:** Unclosed interval doesn't contribute to daily total

### Test 9.2: Multiple Days
- [ ] Create timesheet for today
- [ ] Manually create file for yesterday with different date
- [ ] Run `:EpochReport`

**Expected:** Report shows data from multiple days in current week

### Test 9.3: Invalid Lua Syntax
- [ ] Manually corrupt timesheet with invalid Lua syntax
- [ ] Try to save

**Expected:** Clear error message about syntax error

### Test 9.4: Rapid Interval Creation (Sub-Minute Succession)
- [ ] Run `:EpochInterval` and create first interval (client1, project1, task1)
- [ ] Immediately run `:EpochInterval` again (within same minute)
- [ ] Create second interval (client2, project2, task2)
- [ ] Immediately run `:EpochInterval` again (within same minute)
- [ ] Create third interval (client3, project3, task3)
- [ ] Run `:EpochEdit` to examine the intervals

**Expected:**
- No overlapping intervals exist
- Each interval has sequential start times (shifted forward by 1 minute)
- Previous intervals properly closed with stop times
- Intervals appear in chronological order
- No validation errors about overlaps

---

## Test Group 10: Cleanup Operations

### Test 10.1: Clear All Data
- [ ] Run `:EpochClear`
- [ ] Confirm deletion

**Expected:**
- Confirmation prompt appears
- All timesheet files deleted
- Fresh start possible

### Test 10.2: Cancel Clear Operation
- [ ] Run `:EpochClear`
- [ ] Cancel/decline deletion

**Expected:** No files deleted, operation cancelled

---

## Test Group 11: UI Behavior

### Test 11.1: Window Sizing
- [ ] Test edit window sizing (should be 40% width, 70% height)
- [ ] Test report window sizing (should be 50% width, 60% height)

**Expected:** Windows appear at correct sizes

### Test 11.2: Syntax Highlighting
- [ ] Open edit window
- [ ] Verify Lua syntax highlighting

**Expected:** Lua syntax highlighting active in edit window

### Test 11.3: Multiple Window Management
- [ ] Open `:EpochEdit`
- [ ] Without closing, run `:EpochReport`

**Expected:** Report opens, edit window behavior defined

### Test 11.4: Floating Window Scrolling with Large Content
- [ ] Create multiple intervals (10+ entries) to exceed floating window height
- [ ] Run `:EpochEdit`
- [ ] Verify window size remains at 40% width, 70% height
- [ ] Test scrolling with `j`/`k` (down/up)
- [ ] Test scrolling with `h`/`l` (left/right for long lines)
- [ ] Test `gg` (go to top) and `G` (go to bottom)
- [ ] Test `Ctrl-u`/`Ctrl-d` (page up/down)

**Expected:** 
- Window size unchanged regardless of content length
- All vi navigation bindings work normally
- Content scrolls within fixed window boundaries
- Can access all content via scrolling

---

## Summary

- **Total Test Groups:** 11
- **Total Test Cases:** 25
- **Focus:** Each test validates a single aspect of functionality
- **Coverage:** All core features, edge cases, and error conditions

Each test should be performed independently to isolate functionality and identify specific issues.