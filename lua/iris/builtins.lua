local B = {}

-- ANSI-first
function B.mira()
  return function()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
    vim.o.background = "dark"
    vim.opt.termguicolors = false
    local ok = pcall(require, "mira"); if not ok then return false, "mira not installed" end
    pcall(vim.cmd.colorscheme, "mira")
    return true
  end
end

function B.nord()
  return function()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
    vim.o.background = "dark"
    vim.opt.termguicolors = true
    pcall(vim.cmd.colorscheme, "nord")
    return true
  end
end

function B.rose_pine(opts)
  opts = opts or {}
  local variant = opts.default_variant or vim.g.rose_pine_default_variant or "main"  -- main|moon|dawn
  return function()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
    vim.o.background = (variant == "dawn") and "light" or "dark"
    vim.opt.termguicolors = true
    local ok, rp = pcall(require, "rose-pine")
    if ok and rp and rp.setup then rp.setup({ variant = variant, dark_variant = variant }) end
    pcall(vim.cmd.colorscheme, "rose-pine")
    return true
  end
end

function B.catppuccin(opts)
  opts = opts or {}
  local flavour = opts.default_flavour or vim.g.catppuccin_flavour or "mocha"  -- latte|frappe|macchiato|mocha
  return function()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
    vim.o.background = (flavour == "latte") and "light" or "dark"
    vim.opt.termguicolors = true
    local ok, c = pcall(require, "catppuccin")
    if ok and c and c.setup then
      c.setup({ flavour = flavour, background = { light = "latte", dark = flavour }, transparent_background = vim.g.catppuccin_transparent or false })
    end
    pcall(vim.cmd.colorscheme, "catppuccin")
    return true
  end
end

function B.tokyonight(opts)
  opts = opts or {}
  local style = opts.default_style or vim.g.tokyonight_style or "storm"   -- storm|night|moon
  return function()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
    vim.o.background = "dark"
    vim.opt.termguicolors = true
    local ok, tn = pcall(require, "tokyonight")
    if ok and tn and tn.setup then tn.setup({ style = style, light_style = "day" }) end
    pcall(vim.cmd.colorscheme, "tokyonight")
    return true
  end
end

return B
