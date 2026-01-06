-- ~/.config/nvim/lua/config/ui.lua

-- Try to load devicons (optional)
local has_devicons, devicons = pcall(require, "nvim-web-devicons")

-- TABLINE --------------------------------------------------------------------
vim.o.showtabline = 2               -- always show tabline
vim.o.tabline = "%!v:lua.TabLine()" -- use Lua function

function _G.TabLine()
  local api = vim.api
  local fn = vim.fn

  local s = ""
  local current = api.nvim_get_current_buf()
  local buffers = api.nvim_list_bufs()
  local first = true

  for _, buf in ipairs(buffers) do
    if api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      local name = fn.fnamemodify(api.nvim_buf_get_name(buf), ":t")
      if name == "" then
        name = "[No Name]"
      end

      -- devicon
      local icon = ""
      if has_devicons and devicons then
        local ext = fn.fnamemodify(name, ":e")
        local ico = devicons.get_icon(name, ext, { default = true })
        if ico then
          icon = ico .. " "
        end
      end

      -- truncate if too long
      if fn.strdisplaywidth(name) > 15 then
        name = fn.strcharpart(name, 0, 12) .. "…"
      end

      local modified = vim.bo[buf].modified and " ●" or ""

      if not first then
        s = s .. "%#TabLineSeparator#│"
      end
      first = false

      local label = icon .. name .. modified .. " ✗ "

      if buf == current then
        s = s .. ("%#TabLineSel# " .. label)
      else
        s = s .. ("%#TabLine# " .. label)
      end
    end
  end

  if s == "" then
    s = "%#TabLineFill#"
  end

  return s
end

-- STATUSLINE -----------------------------------------------------------------
local mode_map = {
  ["n"] = "NORMAL",
  ["i"] = "INSERT",
  ["v"] = "VISUAL",
  ["V"] = "V-LINE",
  [""] = "V-BLOCK",
  ["c"] = "COMMAND",
  ["R"] = "REPLACE",
  ["t"] = "TERMINAL",
}

function _G.Statusline()
  local mode = mode_map[vim.fn.mode()] or vim.fn.mode()
  local fname = vim.fn.expand("%:t")
  if fname == "" then
    fname = "[No Name]"
  end

  local icon = ""
  if has_devicons and devicons then
    local ext = vim.fn.expand("%:e")
    icon = devicons.get_icon(fname, ext, { default = true }) or ""
    if icon ~= "" then
      icon = icon .. " "
    end
  end

  local pos = "%l:%c"

  return string.format("  %s │ %s%s %%=%s ", mode, icon, fname, pos)
end

vim.o.statusline = "%!v:lua.Statusline()"

-- HIGHLIGHTS -----------------------------------------------------------------

-- transparent statusline/tabline
vim.api.nvim_set_hl(0, "StatusLine",   { bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })

vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })

-- Inactive buffers (dim)
vim.api.nvim_set_hl(0, "TabLine", {
  fg = "#6B7280", -- dim grey-ish
  bg = "NONE",
})

-- Active buffer (bold)
vim.api.nvim_set_hl(0, "TabLineSel", {
  fg = "NONE",
  bg = "NONE",
  bold = true,
})

-- Separator color
vim.api.nvim_set_hl(0, "TabLineSeparator", {
  fg = "#434C5E",
  bg = "NONE",
})
