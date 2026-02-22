require('nvim-treesitter.configs').setup({
  ensure_installed = "all",

  ignore_install = { "ocamllex", "scfg", "teal", "d", "swift", "mlir", "wing" },

  highlight = {
    enable = true,
  },
})
