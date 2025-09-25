# iris

**Neovim theme loader + picker** — centralize all your colorscheme logic, switch “families,” and live‑preview with Telescope.

<p align="center">
  <img alt="iris: theme loader + picker for Neovim" src="https://img.shields.io/badge/nvim-theme%20loader-iris.svg">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-green.svg">
</p>

## Why iris?

Keeping theme code inside your dotfiles gets noisy fast. **iris** pulls all the **loader / toggle / preview** logic into a tiny plugin so your local config stays clean and modular.

- Theme **families**: map a friendly name to a full apply function (e.g. `mira`, `nord`, `rose-pine` with variant setup).
- **Live preview**: Telescope picker with instant switching, defaulting to your current theme.
- **Commands**: `:ThemeUse`, `:ThemeToggle`, `:ThemeStatus`.
- **Smart default**: honors `g:theme_default` or `NVIM_THEME`.
- **Opt‑in keys**: quick theme mappings, easy to disable.
- **Lazy-aware**: preloads theme plugins so variants show up in the picker.

> Works great if you keep multiple colorscheme plugins installed and bounce between **ANSI** and **truecolor** modes.

---

## Install (lazy.nvim)

```lua
-- in your plugins list
{
  "suhailphotos/iris",
  lazy = false, -- ensure commands are defined on startup
  dependencies = {
    -- optional but recommended for the picker
    { "nvim-telescope/telescope.nvim" },

    -- your theme plugins; names must match the family keys you use
    { "rose-pine/neovim", name = "rose-pine" },
    { "shaunsingh/nord.nvim", name = "nord" },
    -- { "your/mira", name = "mira" }, -- if you have a 'mira' theme
  },
  config = function()
    require("iris").setup({
      -- default theme (overridden by NVIM_THEME or g:theme_default)
      default = "mira",
      enable_keymaps = true, -- set false to skip <leader>t* maps
      families = {
        -- Add or override families here (optional).
        -- A family is a function that returns true, or (false, "msg") on failure.
        -- Example adding gruvbox:
        -- gruvbox = function()
        --   vim.opt.termguicolors = true
        --   pcall(vim.cmd.colorscheme, "gruvbox")
        --   return true
        -- end,
      },
    })

    -- Apply your default theme on startup:
    require("iris").apply_default()
  end,
}
```

### Alternative managers

If you’re not on lazy.nvim, just ensure `require("iris")` is available and call `require("iris").apply_default()` during init. For packer, put iris in `use { ... }` and call in your config block.

---

## Usage

### Commands

- `:ThemeUse <name>` — apply a theme by **family** or plain colorscheme name.
- `:ThemeToggle` — quick switch between two familiar choices (default: `mira` ↔ `nord`).
- `:ThemeStatus` — show current theme and `termguicolors` state.

### Picker

Open the Telescope picker (live preview while you move the selection):

```lua
-- map something in your config, e.g.:
vim.keymap.set("n", "<leader>tp", function() require("iris.picker").open() end, { desc = "Theme: pick" })
```

The picker shows your **families** first (e.g. `mira`, `nord`, `rose-pine`) followed by every installed colorscheme that isn’t already a family label. It tries to **preload** family plugins via lazy.nvim so variants like `rose-pine-dawn` appear.

It also tries to start with your **current** theme highlighted.

### Defaults & knobs

- Default theme comes from, in order:
  1. `vim.g.theme_default`
  2. `NVIM_THEME` environment variable
  3. `setup{ default = "mira" }` (or `"nord"`, etc.)

- Disable built‑in keymaps (set before loading iris or via `setup`):
  ```lua
  require("iris").setup({ enable_keymaps = false })
  ```

- Add/override families at setup time:
  ```lua
  require("iris").setup({
    families = {
      rose_pine = nil, -- remove/override a family
      tokyonight = function()
        vim.opt.termguicolors = true
        pcall(vim.cmd.colorscheme, "tokyonight-night")
        return true
      end,
    }
  })
  ```

---

## API

```lua
local iris = require("iris")

iris.setup({
  default = "mira",          -- fallback default
  enable_keymaps = true,     -- register <leader>tm/<leader>tn/<leader>tt
  families = {               -- merge/override family map
    -- name = function() ... return true end
  },
})

iris.use("nord")             -- apply a family or plain colorscheme (by name)
iris.toggle()                -- toggle between two common families
iris.apply_default()         -- resolve g:theme_default/NVIM_THEME/default and apply
iris.list()                  -- return sorted list of family names
```

Picker:

```lua
require("iris.picker").open()
```

---

## Keymaps (optional defaults)

If `enable_keymaps = true`, iris registers:

- `<leader>tm` → `:ThemeUse mira`
- `<leader>tn` → `:ThemeUse nord`
- `<leader>tt` → `:ThemeToggle`

You can disable them and define your own bindings instead.

---

## Migrate your local config

1. Remove/rename your old theme files (e.g. `lua/suhail/theme.lua`, `lua/suhail/theme_picker.lua`).  
2. Install **iris** as a plugin (see lazy.nvim block above).  
3. Replace calls:
   - `require("suhail.theme").apply_default()` → `require("iris").apply_default()`
   - `require("suhail.theme").use("...")` → `require("iris").use("...")`
   - `require("suhail.theme_picker").open()` → `require("iris.picker").open()`

4. If you had custom families, add them under `setup{ families = { ... } }`.

---

## Notes on truecolor vs ANSI

Some themes (like your `mira` ANSI mode) prefer `termguicolors = false`.  
Families are free to set this per‑apply. For example:

```lua
mira = function()
  local ok = pcall(require, "mira"); if not ok then return false, "mira not installed" end
  vim.g.mira_ansi_only = true
  vim.opt.termguicolors = false
  pcall(vim.cmd.colorscheme, "mira")
  return true
end
```

While others enable truecolor:

```lua
nord = function()
  vim.opt.termguicolors = true
  pcall(vim.cmd.colorscheme, "nord")
  return true
end
```

---

## Troubleshooting

- **“Unknown theme” warning**: `:ThemeUse blah` → ensure `blah` is a family name you defined or an installed colorscheme.  
- **Rose‑pine variants missing**: ensure the plugin is declared with `name = "rose-pine"` and Telescope is installed; iris asks lazy.nvim to preload family plugins before listing.  
- **Picker starts at top**: some Telescope builds ignore `default_selection_index`; iris tries a fallback `set_selection` on attach.  
- **Colors look wrong after preview**: on cancel, iris restores your previous `termguicolors` and colorscheme.

---

## Minimal plugin layout

```
lua/iris/init.lua        -- loader (setup/use/toggle/apply_default/list)
lua/iris/picker.lua      -- Telescope UI + preview
plugin/iris.lua          -- user commands & (optional) default keymaps
```

You can keep everything in `lua/iris/` if you prefer; Neovim loads `plugin/*.lua` on startup.

---

## License

MIT © You. See `LICENSE`.
