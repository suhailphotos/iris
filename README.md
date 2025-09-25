# iris

**Neovim theme loader + picker** — centralize colorscheme logic, switch “families,” and live-preview with Telescope.

<p align="center">
  <img alt="iris: theme loader + picker for Neovim" src="https://img.shields.io/badge/nvim-theme%20loader-iris.svg">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-green.svg">
</p>

---

## Why iris?

Stuffing theme logic into your dotfiles gets noisy. **iris** is a tiny plugin that owns the **apply / toggle / preview** flow so your main config stays clean.

- **Families**: friendly names that run a full apply function (e.g. `mira`, `nord`, `rose-pine` w/ variant, `catppuccin` w/ flavour, `tokyonight` w/ style).
- **Live preview**: Telescope picker with instant apply while you move selection.
- **Picker hygiene**: temporarily uses a global statusline and clears per-window overrides for accurate previews.
- **Commands**: `:IrisUse`, `:IrisToggle`, `:IrisPick`, `:IrisStatus`, `:IrisReapply`.
- **Smart default**: respects `g:theme_default` or `NVIM_THEME`.
- **Lazy-aware**: preloads family plugins so variants appear.

Works great whether you bounce between **ANSI** (16-color) and **truecolor** themes.

---

## Install (lazy.nvim)

```lua
-- in your plugin spec
{
  "suhailphotos/iris",
  name = "iris",
  lazy = false,           -- apply early; define commands at startup
  priority = 1000,        -- win the colorscheme race
  dependencies = {
    { "nvim-telescope/telescope.nvim", optional = true },  -- for the picker
    { "suhailphotos/mira",        name = "mira" },         -- ANSI-first theme
    { "nordtheme/vim",            name = "nord" },
    { "rose-pine/neovim",         name = "rose-pine" },
    { "catppuccin/nvim",          name = "catppuccin" },
    { "folke/tokyonight.nvim",    name = "tokyonight" },
  },
  opts = {
    -- fallback when neither g:theme_default nor NVIM_THEME is set
    default = "mira",
    -- families = { ... } -- optional: add/override families here
  },
}
```

Not using lazy.nvim? Just make sure `require("iris")` is on `runtimepath` and call `require("iris").setup{...}` during init.

---

## Built-in families

Iris ships wrappers that **clear highlights**, **reset syntax**, and set background / truecolor appropriately:

- `mira` — ANSI-first. Sets `background=dark`, `termguicolors=false`, then `colorscheme mira`.
- `nord` — Truecolor. `termguicolors=true`, `colorscheme nord`.
- `rose-pine` — Truecolor. Variant via `g:rose_pine_default_variant` or `{ default_variant = "main|moon|dawn" }`. Sets `background=light` for `dawn`, otherwise `dark`.
- `catppuccin` — Truecolor. Flavour via `g:catppuccin_flavour` or `{ default_flavour = "mocha|macchiato|frappe|latte" }`. Sets `background=light` for `latte`, otherwise `dark`.
- `tokyonight` — Truecolor. Style via `g:tokyonight_style` or `{ default_style = "storm|night|moon" }`. Uses `light_style="day"` when needed.

You can override or add families in `setup{ families = { ... } }`.

---

## Commands

- `:IrisUse <name>` — apply a **family** (e.g. `mira`) or directly a colorscheme name.
- `:IrisToggle` — toggle between the first two family names (sorted).
- `:IrisPick` — open the Telescope picker (or a `vim.ui.select` fallback).
- `:IrisStatus` — show current theme + `termguicolors` state.
- `:IrisReapply` — force-reapply the current theme and refresh the UI (clears per-window `winhighlight`, redraws statusline).

---

## API

```lua
local iris = require("iris")

iris.setup({
  default  = "mira",
  families = {
    -- override or add:
    -- gruvbox = function()
    --   vim.cmd("hi clear")
    --   if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
    --   vim.o.background = "dark"
    --   vim.opt.termguicolors = true
    --   pcall(vim.cmd.colorscheme, "gruvbox")
    --   return true
    -- end,
  },
})

iris.use("nord")     -- apply by family or raw colorscheme name
iris.toggle()        -- flip between two families
iris.list()          -- sorted list of family names
iris.pick()          -- open picker programmatically
iris.status()        -- { current = "nord", termguicolors = true }
iris.reapply()       -- hard refresh current theme
```

**Defaults resolution** (first hit wins):

1. `vim.g.theme_default`
2. `NVIM_THEME` environment variable
3. `opts.default` (setup)

---

## Picker details

- Builds a list of **families** first, then all installed colorschemes (`:h getcompletion('', 'color')`) that aren’t already family names.
- Preloads family plugins via lazy.nvim so scheme variants (like `rose-pine-dawn`, `tokyonight-day`) show up.
- While the picker is open, iris:
  - sets `laststatus=3` (global statusline) for consistent preview,
  - clears per-window `winhighlight` on each apply,
  - and on cancel restores your prior scheme + `termguicolors`.

**Keymap example**

```lua
-- in your config
vim.keymap.set("n", "<leader>ts", function()
  local ok, iris = pcall(require, "iris"); if ok then iris.pick() end
end, { desc = "Theme: search & switch" })
```

---

## ANSI vs Truecolor

- **ANSI mode** (`mira`): `termguicolors=false` so highlights use `ctermfg/ctermbg` and read your terminal’s 16-color palette. Great for consistent TUI/CLI across hosts.
- **Truecolor mode** (nord/rose-pine/catppuccin/tokyonight): `termguicolors=true` and colors come from the theme.

Switch freely; `:IrisStatus` confirms the current `termguicolors` state.

---

## Troubleshooting

- **Statusline looks “dim” during preview**: NC vs active bars can be confusing. The picker temporarily uses a global statusline; if you like that always, set:
  ```lua
  vim.opt.laststatus = 3
  ```
- **Stale UI after lots of swaps**: run `:IrisReapply` to re-apply and clear window-local overrides.
- **Family missing**: ensure the plugin exists and the family name matches the dependency `name` (e.g. `name = "rose-pine"`).
- **`mira` not installed**: install `suhailphotos/mira` or switch defaults.
- **Variants not appearing**: make sure Telescope is available; iris preloads families via lazy when the picker opens.

---

## Minimal layout

```
/lua/iris/
  init.lua      -- setup/use/toggle/list/status/reapply
  picker.lua    -- Telescope UI + live preview
  builtins.lua  -- family apply functions (mira, nord, rose-pine, catppuccin, tokyonight)
```

---

## License

MIT. See `LICENSE`.
