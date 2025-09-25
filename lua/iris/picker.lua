local P = {}

local function norm(s) return (s:gsub("[_%s]", "-"):lower()) end

local function build_entries(core)
  local families_norm, entries = {}, {}

  for _, n in ipairs(core.list()) do
    families_norm[norm(n)] = true
    table.insert(entries, { name = n, from = "family" })
  end

  for _, n in ipairs(vim.fn.getcompletion("", "color")) do
    if not families_norm[norm(n)] then
      table.insert(entries, { name = n, from = "colorscheme" })
    end
  end

  table.sort(entries, function(a, b) return a.name < b.name end)
  return entries
end

local function find_default_index(entries, families)
  local cur = vim.g.colors_name or ""
  if cur == "" then return 1 end

  for i, e in ipairs(entries) do
    if e.name == cur then return i end
  end

  for _, fam in ipairs(families) do
    if cur:find(fam, 1, true) then
      for i, e in ipairs(entries) do
        if e.name == fam and e.from == "family" then return i end
      end
    end
  end
  return 1
end

local function apply(core, name, from)
  if from == "family" then
    core.use(name); return
  end
  vim.opt.termguicolors = true
  vim.cmd("hi clear")
  pcall(vim.cmd.colorscheme, name)
end

local function preload_theme_plugins(family_names)
  local ok, lazy = pcall(require, "lazy")
  if ok then pcall(lazy.load, { plugins = family_names }) end
end

function P.open(core)
  preload_theme_plugins(core.list())
  local entries = build_entries(core)

  local orig = { name = vim.g.colors_name, tgc = vim.o.termguicolors }
  local ok_t = pcall(require, "telescope")
  if not ok_t then
    local choices = {}
    for _, e in ipairs(entries) do table.insert(choices, e.name) end
    vim.ui.select(choices, { prompt = "Theme" }, function(choice)
      if not choice then return end
      for _, e in ipairs(entries) do
        if e.name == choice then apply(core, e.name, e.from); break end
      end
    end)
    return
  end

  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local last_previewed, gen = nil, 0
  local function restore()
    vim.opt.termguicolors = orig.tgc
    if orig.name and orig.name ~= "" then pcall(vim.cmd.colorscheme, orig.name)
    else pcall(vim.cmd.colorscheme, "default") end
    last_previewed = nil
  end
  local function schedule_preview(bufnr)
    gen = gen + 1
    local mygen = gen
    vim.schedule(function()
      if mygen ~= gen then return end
      local e = action_state.get_selected_entry()
      if not e or not e.value then return end
      local key = e.value.from .. "::" .. e.value.name
      if key == last_previewed then return end
      apply(core, e.value.name, e.value.from)
      last_previewed = key
    end)
  end

  local default_idx = find_default_index(entries, core.list())

  pickers.new({}, {
    prompt_title = "Themes",
    finder = finders.new_table({
      results     = entries,
      entry_maker = function(it) return { value = it, display = it.name, ordinal = it.name } end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = false,
    default_selection_index = default_idx,
    attach_mappings = function(bufnr, map)
      local function move_then_preview(fn) return function() fn(bufnr); schedule_preview(bufnr) end end
      local NEXT, PREV = actions.move_selection_next, actions.move_selection_previous
      for _, k in ipairs({ "j", "<Down>", "<C-n>", "<Tab>", "<C-j>" }) do
        map("n", k, move_then_preview(NEXT)); map("i", k, move_then_preview(NEXT))
      end
      for _, k in ipairs({ "k", "<Up>", "<C-p>", "<S-Tab>", "<C-k>" }) do
        map("n", k, move_then_preview(PREV)); map("i", k, move_then_preview(PREV))
      end

      local function confirm() actions.close(bufnr) end
      local function cancel() restore(); actions.close(bufnr) end
      map("n", "<CR>", confirm); map("i", "<CR>", confirm)
      map("n", "<Esc>", cancel);  map("i", "<Esc>", cancel)
      map("n", "<C-c>", cancel);  map("i", "<C-c>", cancel)

      -- robust initial selection even on older Telescope
      vim.schedule(function()
        local picker = action_state.get_current_picker(bufnr)
        if picker and picker.set_selection then
          pcall(picker.set_selection, picker, default_idx - 1)
        else
          for _ = 2, default_idx do actions.move_selection_next(bufnr) end
        end
        local e = entries[default_idx]
        last_previewed = e.from .. "::" .. e.name
      end)
      return true
    end,
  }):find()
end

return P
