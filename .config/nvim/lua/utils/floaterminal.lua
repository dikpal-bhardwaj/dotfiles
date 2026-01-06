-- lua/utils/float.lua

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

local state = {
	floating = {
		buf = -1,
		win = -1,
	}
}

local function open_centered_float(opts)
  opts = opts or {}

  -- Get current UI size
  local ui = vim.api.nvim_list_uis()[1]
  local total_width = ui.width
  local total_height = ui.height

  -- Default to 80% of the editor size
  local width = opts.width or math.floor(total_width * 0.8)
  local height = opts.height or math.floor(total_height * 0.8)

  -- Center the window
  local col = math.floor((total_width - width) / 2)
  local row = math.floor((total_height - height) / 2)

  -- Create scratch buffer
  local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	-- Create the config
	local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  }

  -- Open the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local toggle_terminal = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = open_centered_float { buf = state.floating.buf }
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.term()
		end
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.keymap.set({ "n", "t" }, "<leader>tt", toggle_terminal, { desc = "Toggle floating terminal" })
