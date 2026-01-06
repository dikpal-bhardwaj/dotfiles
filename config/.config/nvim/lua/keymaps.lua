-- ~/.config/nvim/lua/keymaps.lua
require 'utils.floaterminal'
-- code-runner
local runner = require 'utils.runner'

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Disable spacebar in normal & visual (so <leader> works clean)
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Basic quality-of-life
map("n", "<leader>o", ":update<CR> :source<CR>", opts)
map("n", "<C-s>", ":write<CR>", opts)
map("n", "<C-q>", ":quit<CR>", opts)

-- Mini.pick (file picker / help)
map("n", "<leader>f", ":Pick files<CR>", opts)
map("n", "<leader>h", ":Pick help<CR>", opts)

-- Netrw explorer
map("n", "<leader>e", "<cmd>Ex<CR>", { desc = "Open Netrw (file explorer)" })

-- LSP format
-- map("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP format" })

-- Buffer navigation
map("n", "<Tab>", ":bnext<CR>", opts)
map("n", "<S-Tab>", ":bprevious<CR>", opts)
map("n", "<leader>x", ":bdelete!<CR>", opts) -- close buffer
map("n", "<leader>b", "<cmd>enew<CR>", opts) -- new buffer

-- Split / window management
map("n", "<C-k>", ":wincmd k<CR>", opts)
map("n", "<C-j>", ":wincmd j<CR>", opts)
map("n", "<C-h>", ":wincmd h<CR>", opts)
map("n", "<C-l>", ":wincmd l<CR>", opts)

map("n", "<leader>sv", "<C-w>v", opts)      -- vertical split
map("n", "<leader>sh", "<C-w>s", opts)      -- horizontal split
map("n", "<leader>se", "<C-w>=", opts)     -- equalize splits
map("n", "<leader>xs", ":close<CR>", opts) -- close split

-- custom utils

-- Code runner function
vim.keymap.set('n', '<leader>r', runner.run, { noremap = true, silent = true, desc = 'Run current file' })
