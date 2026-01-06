-- ~/.config/nvim/lua/options.lua

-- Leader must be set early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- UI / behavior
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.swapfile = false
vim.o.cursorcolumn = false
vim.o.ignorecase = true
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.incsearch = true
vim.o.winborder = "rounded"

-- Use system clipboard
vim.o.clipboard = "unnamedplus"

-- Better completion behavior
vim.o.completeopt = (vim.o.completeopt .. ",noselect")

-- Hide end-of-buffer markers
vim.opt.fillchars = { eob = " " }
