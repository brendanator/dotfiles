return {
  -- Neotest-python: match old vim-test pytest options
  -- opts are passed through neotest's adapters config, not the plugin directly
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          args = { "--tb=short" },
        },
      },
    },
  },
}
