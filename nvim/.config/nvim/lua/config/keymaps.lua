local map = vim.keymap.set

-- j/k navigate visual lines
map("n", "j", "gj", { desc = "Down (visual line)" })
map("n", "k", "gk", { desc = "Up (visual line)" })
map("n", "gj", "j", { desc = "Down (real line)" })
map("n", "gk", "k", { desc = "Up (real line)" })

-- Arrow keys resize windows
map("n", "<Up>", "<c-w>2-", { desc = "Shrink window vertically" })
map("n", "<Down>", "<c-w>2+", { desc = "Grow window vertically" })
map("n", "<Left>", "<c-w>2<", { desc = "Shrink window horizontally" })
map("n", "<Right>", "<c-w>2>", { desc = "Grow window horizontally" })

-- Yank paths to clipboard
map("n", "<leader>yp", ':let @*=expand("%")<CR>', { desc = "Yank relative path" })
map("n", "<leader>yP", ':let @*=expand("%:p")<CR>', { desc = "Yank absolute path" })
map("n", "<leader>yf", ':let @*=expand("%:t")<CR>', { desc = "Yank filename" })
map("n", "<leader>yd", ':let @*=expand("%:p:h")<CR>', { desc = "Yank directory" })
map("n", "<leader>yl", ':let @*=expand("%").":".line(".")<CR>', { desc = "Yank path:line" })

-- Window navigation by number
for i = 1, 9 do
  map("n", "<leader>" .. i, i .. "<c-w><c-w>", { desc = "Go to window " .. i })
end

-- Alternate buffer
map("n", "<leader><tab>", "<c-^>", { desc = "Alternate buffer" })

-- Save file
map("n", "<leader>fs", "<cmd>write<cr>", { desc = "Save file" })

-- Command line navigation
map("c", "<c-j>", "<down>")
map("c", "<c-k>", "<up>")

-- Escape doesn't move cursor back
map("i", "<Esc>", "<Esc>`^")

-- Filetype shortcuts
map("n", "<leader>ftm", "<cmd>set filetype=markdown<cr>", { desc = "Set filetype markdown" })
map("n", "<leader>ftp", "<cmd>set filetype=python<cr>", { desc = "Set filetype python" })

-- Sort lines and jq (visual mode replacements for vim-toop)
map("v", "<leader>ss", ":'<,'>!sort<CR>", { desc = "Sort lines" })
map("v", "<leader>jq", ":'<,'>!jq<CR>", { desc = "Format with jq" })

