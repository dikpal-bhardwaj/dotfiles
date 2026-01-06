-- ~/.config/nvim/lua/config/lazy.lua

-- Bootstrap lazy.nvim --------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup ---------------------------------------------------------------
require("lazy").setup({
	---------------------------------------------------------------------------
	-- Colorscheme: vague.nvim
	---------------------------------------------------------------------------
	{
		"vague2k/vague.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("vague").setup({ transparent = true })
			vim.cmd("colorscheme vague")
		end,
	},

	---------------------------------------------------------------------------
	-- Mini.pick (fuzzy finder)
	---------------------------------------------------------------------------
	{
		"echasnovski/mini.pick",
		version = false,
		config = function()
			require("mini.pick").setup()
		end,
	},

	---------------------------------------------------------------------------
	-- Markdown preview-ish UI
	---------------------------------------------------------------------------
	{ "OXY2DEV/markview.nvim" },

	---------------------------------------------------------------------------
	-- Mason (LSP/DAP/Linter manager)
	---------------------------------------------------------------------------
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	---------------------------------------------------------------------------
	-- LSP config
	---------------------------------------------------------------------------
	{
  "neovim/nvim-lspconfig",
  lazy = false,
	},

	---------------------------------------------------------------------------
	-- Treesitter
	---------------------------------------------------------------------------
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua", "cpp", "python", "typescript", "javascript",
					"html", "css", "markdown", "markdown_inline",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	---------------------------------------------------------------------------
	-- Completion + Snippets: nvim-cmp + LuaSnip
	---------------------------------------------------------------------------
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"rafamadriz/friendly-snippets",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- LuaSnip setup
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			-- Load VSCode-style snippets
			pcall(function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end)

			-- Custom C++ snippet (boiler)
			local s = luasnip.snippet
			local t = luasnip.text_node
			local i = luasnip.insert_node

			luasnip.add_snippets("cpp", {
				s("boiler", {
					t({
						"#include <iostream>",
						"#include <string>",
						"",
						"using namespace std;",
						"",
						"int main() {",
						"\t",
					}),
					i(0),
					t({ "","\treturn 0;", "}" }),
				}),
			})

			-- nvim-cmp setup
			local cmp = require("cmp")

			local kind_icons = {
				Text = "󰉿",
				Method = "m",
				Function = "󰊕",
				Constructor = "",
				Field = "",
				Variable = "󰆧",
				Class = "󰌗",
				Interface = "",
				Module = "",
				Property = "",
				Unit = "",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "󰈙",
				Reference = "",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰇽",
				Struct = "",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "󰊄",
			}

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete({}),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						vim_item.kind = string.format("%s", kind_icons[vim_item.kind] or "")
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
			})
		end,
	},

	---------------------------------------------------------------------------
	-- Autopairs
	---------------------------------------------------------------------------
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local npairs = require("nvim-autopairs")

			npairs.setup({
				check_ts = true, -- Treesitter-aware autopairs
				disable_filetype = { "TelescopePrompt", "vim" },
			})

			-- Optional: auto-pairs integration with nvim-cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	---------------------------------------------------------------------------
	-- Comment.nvim
	---------------------------------------------------------------------------
	{
		"numToStr/Comment.nvim",
		config = function()
			local comment = require("Comment")
			comment.setup()

			local api = require("Comment.api")
			local map = vim.keymap.set
			local opts = { noremap = true, silent = true }

			-- Normal mode
			map("n", "<C-_>", api.toggle.linewise.current, opts)
			map("n", "<C-c>", api.toggle.linewise.current, opts)
			map("n", "<C-/>", api.toggle.linewise.current, opts)

			-- Visual mode
			map(
				"v",
				"<C-_>",
				"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
				opts
			)
			map(
				"v",
				"<C-c>",
				"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
				opts
			)
			map(
				"v",
				"<C-/>",
				"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
				opts
			)
		end,
	},

	---------------------------------------------------------------------------
	-- Live server
	---------------------------------------------------------------------------
	{
		"barrett-ruth/live-server.nvim",
		config = function()
			local live_server = require("live-server")
			live_server.setup()

			local map = vim.keymap.set
			map("n", "<leader>ls", "<cmd>LiveServerStart<CR>", { desc = "Start Live Server" })
			map("n", "<leader>lx", "<cmd>LiveServerStop<CR>", { desc = "Stop Live Server" })
		end,
	},

	---------------------------------------------------------------------------
	-- Icons
	---------------------------------------------------------------------------
	{ "nvim-tree/nvim-web-devicons" },

	---------------------------------------------------------------------------
	-- which-key
	---------------------------------------------------------------------------
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup({})
		end,
	},

	---------------------------------------------------------------------------
	-- Maximize/minimize a split
	---------------------------------------------------------------------------
	{
		'szw/vim-maximizer',
		keys = {
			{ '<leader>sm', '<cmd>MaximizerToggle<CR>', desc = 'Maximize/minimize a split' },
		},
	},
})
