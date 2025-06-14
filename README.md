# epoch

lightweight time tracking for neovim. see `:help epoch` for docs.

## dependencies

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [luarocks](https://luarocks.org/) (dev)
- [luacheck](https://luarocks.org/modules/lunarmodules/luacheck) (dev)
- [lust](https://luarocks.org/modules/luarocks/lust) (dev)

## development

```bash
make test coverage laconic lint  # all must pass
make help                        # show targets
```

## data format

timesheets stored as lua files in `stdpath('data')/epoch/YYYY-MM-DD.lua`:

```lua
{
  date = "2025-01-15",
  intervals = {
    {
      client = "acme-corp",
      project = "website-redesign",
      task = "frontend-planning",
      start = "09:00 AM",
      stop = "10:30 AM",
      notes = {}
    }
  },
  daily_total = "01:30"
}
```

## license

mit
