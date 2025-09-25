local B = {}

-- ANSI-first: uses only the 16 terminal colors
function B.mira()
  return function()
    local ok = pcall(require, "mira"); if not ok then return false, "mira not installed" end
    vim.g.mira_ansi_only = true
    vim.opt.termguicolors = false
    vim.cmd("hi clear")
    pcall(vim.cmd.colorscheme, "mira")
    return true
  end
end

-- Truecolor theme
function B.nord()
  return function()
    vim.opt.termguicolors = true
    vim.cmd("hi clear")
    pcall(vim.cmd.colorscheme, "nord")
    return true
  end
end

-- Truecolor theme with variants (main | moon | dawn)
function B.rose_pine(opts)
  opts = opts or {}
  local variant = opts.default_variant or vim.g.rose_pine_default_variant or "main"
  return function()
    vim.opt.termguicolors = true
    vim.cmd("hi clear")
    local ok, rp = pcall(require, "rose-pine")
    if ok and rp and rp.setup then
      rp.setup({ variant = variant, dark_variant = variant })
    end
    pcall(vim.cmd.colorscheme, "rose-pine")
    return true
  end
end

return B
