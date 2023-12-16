-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/local azyvim/config/keymaps.lua
-- Add any additional keymaps here

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
