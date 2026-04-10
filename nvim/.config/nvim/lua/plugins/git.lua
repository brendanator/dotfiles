return {
  -- Gitsigns: custom keymaps matching old vim-gitgutter muscle memory
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map("n", "]h", function()
          gs.nav_hunk("next")
        end, "Next Hunk")
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, "Prev Hunk")

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")

        -- Blame
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Hunk text object")
        map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", "Hunk text object")
      end,
    },
  },

  -- Fugitive + rhubarb for :Git blame, :GBrowse, :Gvdiffsplit
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gvdiffsplit", "GBrowse", "Gread", "Gwrite" },
    dependencies = { "tpope/vim-rhubarb" },
  },

  -- Lazygit in a floating terminal
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
