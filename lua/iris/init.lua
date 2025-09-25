local M = { _families = {}, current = nil, _default = nil }

local builtins = require("iris.builtins")
local picker   = require("iris.picker")

-- opts:
--   families: map<string, function()> (optional override/add)
--   default : string (apply on setup; falls back to env/gvar/"mira")
function M.setup(opts)
  opts = opts or {}

  if not opts.families then
    M._families = {
      mira         = builtins.mira(),
      nord         = builtins.nord(),
      ["rose-pine"] = builtins.rose_pine({ default_variant = vim.g.rose_pine_default_variant or "main" }),
    }
  else
    M._families = opts.families
  end

  M._default = opts.default or vim.g.theme_default or vim.env.NVIM_THEME or "mira"

  -- Commands (no keymaps here; keep your base config clean)
  vim.api.nvim_create_user_command("IrisUse",    function(a) M.use(a.args) end,
    { nargs = 1, complete = function() return M.list() end })
  vim.api.nvim_create_user_command("IrisToggle", function() M.toggle() end, {})
  vim.api.nvim_create_user_command("IrisPick",   function() M.pick() end, {})
  vim.api.nvim_create_user_command("IrisStatus", function()
    vim.notify(("Theme: %s\ntermguicolors=%s"):format(M.current or "(none)", tostring(vim.o.termguicolors)))
  end, {})

  if M._default then pcall(M.use, M._default) end
end

function M.use(name)
  local fn = M._families[name]
  if not fn then return vim.notify("Iris: unknown theme '" .. tostring(name) .. "'", vim.log.levels.WARN) end
  local ok, err = fn()
  if ok == false then
    vim.notify(("Iris: theme '%s' failed: %s"):format(name, err or ""), vim.log.levels.ERROR)
    return
  end
  M.current = name
end

function M.toggle()
  local names = M.list()
  if #names < 2 then return end
  if M.current == names[1] then M.use(names[2]) else M.use(names[1]) end
end

function M.list()
  local t = {}
  for k, _ in pairs(M._families) do table.insert(t, k) end
  table.sort(t)
  return t
end

function M.pick() picker.open(M) end

function M.status() return { current = M.current, termguicolors = vim.o.termguicolors } end

return M
