vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Python provider
vim.g.python3_host_prog = "~/.local/share/virtualenvs/neovim/bin/python"

-- Display
vim.opt.pumheight = 10
vim.opt.inccommand = "split"
vim.opt.gdefault = true
vim.opt.conceallevel = 2

-- Wrapping
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:2"
vim.opt.showbreak = "↪ "
vim.opt.list = true
vim.opt.listchars = { tab = "» ", extends = "›", precedes = "‹", nbsp = "·", trail = "·" }

-- Folding
vim.opt.foldmethod = "manual"
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "0"

-- Background
vim.opt.background = "dark"

-- Grep
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case --hidden"
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- Project-local config
vim.opt.exrc = true
