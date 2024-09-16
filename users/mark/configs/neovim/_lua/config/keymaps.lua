-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/local azyvim/config/keymaps.lua
-- Add any additional keymaps here

require('which-key').add {
  { "<leader>T",        group = "terminal" },
  { "<leader>T<Space>", "<cmd>bo 16sp +term<CR>",        desc = "open" },
  { "<leader>n",        group = "nix" },
  { "<leader>nh",       group = "home-manager" },
  { "<leader>nhs",      "<cmd>!home-manager switch<CR>", desc = "[N]ix::home-manager switch" },
}
