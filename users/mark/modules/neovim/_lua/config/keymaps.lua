-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/local azyvim/config/keymaps.lua
-- Add any additional keymaps here

-- "Very magic mode" by default. Slightly annoying to have it wait for another
-- keystroke after every "s", but better than having to escape every single
-- parenthesis you ever use in a regex replacement.
vim.keymap.set("c", "s/", "s/\\v")
vim.keymap.set("c", "s@", "s@\\v")

require('which-key').register {
  ["<leader>"] = {
    n = {
      name = "nix",
      h = {
        name = "home-manager",
        s = {
          { "<cmd>!home-manager switch<CR>",
            "[N]ix::home-manager switch" },

        },
      },
    },
    T = {
      name = "terminal",
      ["<Space>"] = { "<cmd>bo 16sp +term<CR>", "open" },
    },
  },
}
