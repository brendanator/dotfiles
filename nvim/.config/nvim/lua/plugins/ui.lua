return {
  -- Lualine: show relative file path
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_a = {
        {
          "filename",
          path = 1, -- relative path
        },
      }
    end,
  },
}
