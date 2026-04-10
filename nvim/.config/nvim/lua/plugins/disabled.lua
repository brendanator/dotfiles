return {
  -- Disable flash.nvim (using leap.nvim via editor.leap extra instead)
  { "folke/flash.nvim", enabled = false },

  -- Disable mini.surround (using nvim-surround instead)
  { "nvim-mini/mini.surround", enabled = false },

  -- Disable annoying snacks.nvim animations
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      indent = { animate = { enabled = false } },
    },
  },
}
