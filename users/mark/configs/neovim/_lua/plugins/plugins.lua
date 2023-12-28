return {
  {
    -- not working
    "folke/neodev.nvim",
    opts = {
      override = function(_, library)
        library.enabled = true
        library.runtime = true
        library.types = true
        library.plugins = true
      end,
    }
  },
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { nix = { "alejandra" } } },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["Z"] = "expand_all_nodes",
        }
      }
    }
  },

  {
    "williamboman/mason-lspconfig.nvim",
    enabled = false,
  },

  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      dim_inactive = true,
      transparent = true,
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>fp",
        function()
          require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
    },
    opts = {
      defaults = {
        file_ignore_patterns = {
          "^secrets/.$",
          "^secrets/..$",
          "^secrets/...$",
          "^secrets/....$",
          "^secrets/.*[^%.]...",
          "^secrets/.*.[^n]..",
          "^secrets/.*..[^i].",
          "^secrets/.*..[^x]",
        },
        mappings = {
          i = {
            ["<C-H>"] = "preview_scrolling_left",
            ["<C-J>"] = "move_selection_next",
            ["<C-K>"] = "move_selection_previous",
            ["<C-L>"] = "preview_scrolling_right",
            ["<C-N>"] = "preview_scrolling_down",
            ["<C-P>"] = "preview_scrolling_up",
          }
        }
      },
    }
  },

  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {}
      },
    },
  },

  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },

  {
    url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "awk",
        "bash",
        "c",
        "cmake",
        "cpp",
        "css",
        "csv",
        "cuda",
        "diff",
        "dockerfile",
        "dot",
        "fish",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "gpg",
        "haskell",
        "html",
        "ini",
        "java",
        "javascript",
        "jq",
        "json",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "markdown_inline",
        "nix",
        "python",
        "regex",
        "rust",
        "sql",
        "ssh_config",
        "starlark",
        "toml",
        "tsv",
        "typescript",
        "vim",
        "xml",
        "yaml",
      },
    },
  },
}
