-- Better newline behavior on markdown lists
vim.keymap.set("n", "o", "A<cr>", { buffer = true })
vim.keymap.set("n", "O", "kA<cr>", { buffer = true })
