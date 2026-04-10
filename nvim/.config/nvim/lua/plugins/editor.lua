return {
  -- Tmux navigator
  {
    "christoomey/vim-tmux-navigator",
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
    },
  },

  -- Surround (replaces mini.surround)
  -- v4: keymaps are set via <Plug> mappings, not opts
  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
    event = "VeryLazy",
    init = function()
      -- Disable default keymaps so we can set our own
      vim.g.nvim_surround_no_normal_mappings = true
      vim.g.nvim_surround_no_visual_mappings = true
    end,
    opts = {
      aliases = {
        b = ")",
        B = "}",
        c = "}",
        g = ">",
        r = "]",
        ["'"] = "'",
        d = '"',
        k = "`",
      },
    },
    keys = {
      { "x", "<Plug>(nvim-surround-normal)", desc = "Surround add" },
      { "xx", "<Plug>(nvim-surround-normal-cur)", desc = "Surround add (line)" },
      { "X", "<Plug>(nvim-surround-normal-line)", desc = "Surround add (new lines)" },
      { "XX", "<Plug>(nvim-surround-normal-cur-line)", desc = "Surround add (cur line, new lines)" },
      { "x", "<Plug>(nvim-surround-visual)", mode = "x", desc = "Surround add (visual)" },
      { "X", "<Plug>(nvim-surround-visual-line)", mode = "x", desc = "Surround add (visual line)" },
      { "ds", "<Plug>(nvim-surround-delete)", desc = "Surround delete" },
      { "cs", "<Plug>(nvim-surround-change)", desc = "Surround change" },
      { "cS", "<Plug>(nvim-surround-change-line)", desc = "Surround change (new lines)" },
    },
  },

  -- Telescope <c-p> for find files
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      { "<c-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    },
  },

  -- Telescope undo
  {
    "debugloop/telescope-undo.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>u", "<cmd>Telescope undo<cr>", desc = "Undo tree" },
    },
    config = function()
      require("telescope").load_extension("undo")
    end,
  },

  -- Enhanced text objects
  { "wellle/targets.vim", event = "VeryLazy" },

  -- Alignment
  {
    "tommcdo/vim-lion",
    event = "VeryLazy",
    init = function()
      vim.g.lion_squeeze_spaces = 1
    end,
  },

  -- Swap text regions
  { "tommcdo/vim-exchange", event = "VeryLazy" },

  -- Tpope essentials
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-unimpaired", event = "VeryLazy" },
  { "tpope/vim-abolish", event = "VeryLazy" },
  { "tpope/vim-eunuch", event = "VeryLazy" },
  { "tpope/vim-projectionist", event = "VeryLazy" },
}
