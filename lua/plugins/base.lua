return {
  { "folke/lazy.nvim", tag = "stable" },
  {
    "tpope/vim-surround",
    event = "User FileOpened",
  },
  {
    "tpope/vim-repeat",
    event = "VimEnter",
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      open_mapping = "<C-t>",
      direction = "float",
    },
    cmd = {
      "ToggleTerm",
      "TermExec",
      "ToggleTermToggleAll",
      "ToggleTermSendCurrentLine",
      "ToggleTermSendVisualLines",
      "ToggleTermSendVisualSelection",
    },
    keys = "<C-t>",
  },
  "folke/which-key.nvim",
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
        pickers = {
          buffers = {
            path_display = {
              "shorten",
            },
          },
          -- find_files = {
          --   layout_strategy = "center",
          -- },
          -- git_files = {
          --   layout_strategy = "center",
          -- },
          -- lsp_definitions = {
          --   layout_strategy = "center",
          -- },
          -- lsp_implementations = {
          --   layout_strategy = "center",
          -- },
          -- lsp_references = {
          --   layout_strategy = "center",
          -- },
          -- lsp_type_definitions = {
          --   layout_strategy = "center",
          -- },
        },
        defaults = {
          mappings = {
            -- for input mode
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
            },
            -- for normal mode
            n = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
          layout_strategy = "center",
        },
      })
    end,
    cmd = "WhichKey",
    event = "VeryLazy",
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    lazy = true,
  },
  {
    "gbprod/nord.nvim",
    opts = {
      styles = {
        comments = { italic = false },
      },
    },
    priority = 1000,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
    event = "User FileOpened",
    cmd = "Gitsigns",
  },
  {
    "ggandor/leap.nvim",
    config = function()
      vim.keymap.set("n", "s", "<Plug>(leap-forward-to)", { silent = true })
      vim.keymap.set("x", "z", "<Plug>(leap-forward-to)", { silent = true })
      vim.keymap.set("o", "z", "<Plug>(leap-forward-to)", { silent = true })
      vim.keymap.set("n", "S", "<Plug>(leap-backward-to)", { silent = true })
      vim.keymap.set("x", "Z", "<Plug>(leap-backward-to)", { silent = true })
      vim.keymap.set("o", "Z", "<Plug>(leap-backward-to)", { silent = true })
      vim.keymap.set("x", "x", "<Plug>(leap-forward-till)", { silent = true })
      vim.keymap.set("o", "x", "<Plug>(leap-forward-till)", { silent = true })
      vim.keymap.set("x", "X", "<Plug>(leap-backward-till)", { silent = true })
      vim.keymap.set("o", "X", "<Plug>(leap-backward-till)", { silent = true })
      -- vim.keymap.set("n", "gs", "<Plug>(leap-cross-window)", { silent = true })
      -- vim.keymap.set("x", "gs", "<Plug>(leap-cross-window)", { silent = true })
      -- vim.keymap.set("o", "gs", "<Plug>(leap-cross-window)", { silent = true })
    end,
  },
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    config = function()
      require("auto-save").setup({
        condition = function(buf)
          local fn = vim.fn
          local utils = require("auto-save.utils.data")
          if utils.not_in(fn.getbufvar(buf, "&filetype"), { "oil" }) then
            return true
          end
          return false
        end,
      })
    end,
  },
  {
    "ethanholz/nvim-lastplace",
    event = "BufRead",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = {
          "gitcommit",
          "gitrebase",
          "svn",
          "hgcommit",
        },
        lastplace_open_folds = true,
      })
    end,
  },
  {
    "windwp/nvim-autopairs",
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
        java = false,
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0, -- Offset from pattern match
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
    event = "InsertEnter",
  },
}
