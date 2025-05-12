# epoch

A lightweight time tracking plugin for Neovim.

## Features

- Zero configuration - it just works
- Simple time tracking with minimal overhead
- Floating window interface for timesheets
- Automatic per-day organization
- Weekly reporting
- Client, project, and task tracking
- Lua-formatted timesheets for easy editing

## Installation

Epoch requires [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for floating windows.

Use your plugin manager of choice:

```lua
-- Using paq
require "paq" {
    "nvim-lua/plenary.nvim",
    "ratmav/epoch"
}
```

## Commands

`:EpochEdit` - Toggle today's timesheet in a modifiable floating window

`:EpochInterval` - Create/add a new interval to today's timesheet with client, project, and task

`:EpochReport` - Toggle a non-modifiable weekly report view

`:EpochClear` - Delete all timesheet files (with confirmation)

## Structure

Timesheets are stored as Lua data files and can be directly edited in the floating window. Changes are automatically saved when you close the window.

```lua
{
  date = "2025-05-11",
  completed = false,
  intervals = {
    {
      client = "acme-corp",
      project = "website-redesign",
      task = "frontend-planning",
      start = "09:00 AM",
      ["end"] = "10:30 AM",
    },
  },
  daily_total = "01:30",
}
```

## License

MIT