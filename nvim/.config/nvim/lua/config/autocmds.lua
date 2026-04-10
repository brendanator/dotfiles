local autocmd = vim.api.nvim_create_autocmd

-- Auto-save on focus lost (don't trigger linting/formatting)
autocmd({ "FocusLost", "BufLeave" }, {
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! noautocmd write")
    end
  end,
})

-- Terminal settings
autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
  pattern = "term://*",
  command = "startinsert",
})

autocmd({ "BufLeave", "BufWinLeave" }, {
  pattern = "term://*",
  command = "stopinsert",
})

-- Filetype detection
vim.filetype.add({
  extension = {
    pyi = "python",
  },
  filename = {
    [".coveragerc"] = "toml",
    ["Pipfile"] = "toml",
    ["Pipfile.lock"] = "json",
    ["pylintrc"] = "toml",
    ["setup.cfg"] = "toml",
  },
  pattern = {
    [".env%..*"] = "sh",
    ["git/config%-.*"] = "gitconfig",
  },
})

-- Disable undo for /tmp files
autocmd("BufWritePre", {
  pattern = "/tmp/*",
  callback = function()
    vim.opt_local.undofile = false
  end,
})
