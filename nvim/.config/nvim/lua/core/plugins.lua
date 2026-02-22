local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  { import = "lazyvim.plugins.extras.lang.python" },

  "ellisonleao/gruvbox.nvim",
  "folke/lualine.nvim",
  "mgedmin/python-imports.vim",
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  "nvim-treesitter/nvim-treesitter",

  { "nvim-telescope/telescope.nvim", branch='0.1.x', dependencies = { "nvim-lua/plenary.nvim" } },
  { "stevearc/oil.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
}

local opts = {}

require("lazy").setup(plugins, opts)
