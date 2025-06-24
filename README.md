# epoch

lightweight time tracking for neovim. see `:help epoch` for docs.

## dependencies

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [luarocks](https://luarocks.org/) (dev)
- [luacheck](https://luarocks.org/modules/lunarmodules/luacheck) (dev)
- [lust](https://luarocks.org/modules/luarocks/lust) (dev)

## development

```bash
make check  # run complete workflow: test -> coverage -> laconic -> lint
make help   # show all targets
```

### local development with [paq](https://github.com/savq/paq-nvim)

for local development, configure paq to use your working copy instead of the remote:

```lua
-- in your paq config, replace:
"ratmav/epoch";

-- with:
-- "ratmav/epoch";  -- comment out remote version

-- then add at the end:
vim.opt.runtimepath:append("/path/to/your/epoch")
```

restart neovim to pick up the local version.

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
      hours = 1.5,
      notes = {}
    }
  },
  daily_total = "01:30"
}
```

## license

mit
