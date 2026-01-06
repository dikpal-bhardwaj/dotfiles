-- ~/.config/nvim/lua/config/lsp.lua

-- 1. Capabilities from nvim-cmp so LSP knows about completion/snippets
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- helper: safe format function
local function lsp_format()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  local has_formatter = false
  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/formatting") then
      has_formatter = true
      break
    end
  end

  if has_formatter then
    vim.lsp.buf.format({ async = true })
  else
    vim.notify("No LSP formatter available for this file", vim.log.levels.WARN)
  end
end

-- 2. on_attach: per-buffer keymaps
local function on_attach(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  -- Format with LSP (now safe)
  map("n", "<leader>lf", lsp_format, "LSP Format buffer")
end

-- 3. lua_ls config
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- 4. clangd
vim.lsp.config("clangd", {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- 5. ts_ls
vim.lsp.config("ts_ls", {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- 6. pyright
vim.lsp.config("pyright", {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- 7. Enable these servers globally
vim.lsp.enable({
  "lua_ls",
  "clangd",
  "ts_ls",
  "pyright",
})
