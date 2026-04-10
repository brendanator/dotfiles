vim.opt_local.wildignore:append({ "*.pyc", "*.dist-info", "__pycache__", "_pytest", ".tox" })

-- Quick type: ignore annotation
vim.keymap.set("n", "<leader>ti", "miA  # type: ignore<esc>`i", { buffer = true, desc = "Add type: ignore" })
