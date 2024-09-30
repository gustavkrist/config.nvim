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
      start_in_insert = true,
      persist_mode = false,
    },
    cmd = {
      "ToggleTerm",
      "TermExec",
      "ToggleTermToggleAll",
      "ToggleTermSendCurrentLine",
      "ToggleTermSendVisualLines",
      "ToggleTermSendVisualSelection",
    },
    keys = function()
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
      local function _LAZYGIT_TOGGLE()
        lazygit:toggle()
      end
      return {
        "<C-t>",
        { "<C-t>",      "<cmd>execute v:count . 'ToggleTerm'<CR>",          desc = "Toggle Terminal", noremap = true, silent = true },
        { "<C-t>",      "<Esc><cmd>ToggleTerm<CR>",                         desc = "Toggle Terminal", noremap = true, silent = true },
        { "<leader>gg", _LAZYGIT_TOGGLE,                                    desc = "Lazygit" },
        { "<leader>tg", _LAZYGIT_TOGGLE,                                    desc = "Lazygit" },
        { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",              desc = "Float" },
        { "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Horizontal" },
        { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>",   desc = "Vertical" },
      }
    end,
  },
  {
    "folke/which-key.nvim",
    config = function(_, opts)
      local which_key = require("which-key")
      local mappings = {
        {
          mode = "n",
          { "<leader>o",  group = "Open in" },
          { "<leader>og", group = "Open in GitHub.." },
          { "<leader>g",  group = "Git" },
          { "<leader>n",  group = "Generate Annotations" },
          { "<leader>l",  group = "Lsp" },
          { "<leader>t",  group = "Terminal" },
          { "<leader>s",  group = "Search" },
          { "<leader>S",  group = "Sessions" },
        },
      }
      which_key.setup(opts)
      which_key.add(mappings)
    end,
    opts = {
      plugins = {
        marks = true,       -- shows a list of your marks on ' and `
        registers = true,   -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
          enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
          operators = false,   -- adds help for operators like d, y, ... and registers them for motion / text object completion
          motions = true,      -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true,     -- default bindings on <c-w>
          nav = false,         -- misc bindings to work with windows
          z = true,            -- bindings for folds, spelling and others prefixed with z
          g = true,            -- bindings for prefixed with g
        },
      },
      defaults = {
        delay = 100,
      },
      -- add operators that will trigger motion and text object completion
      -- to enable all native operators, set the preset / operators plugin above
      -- operators = { gc = "Comments" },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
      },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3,                    -- spacing between columns
        align = "left",                 -- align columns left, center or right
      },
      show_help = true,                 -- show help message on the command line when the popup is visible
      spec = {
        { "<BS>",      desc = "Decrement Selection", mode = "x" },
        { "<c-space>", desc = "Increment Selection", mode = { "x", "n" } },
      },
    },
    lazy = true,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local actions = require("telescope.actions")
      return {
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
      }
    end,
    keys = function()
      local function telescope_project_root(picker, opts, style)
        opts = opts or {}
        local project_root = require("util.root")()
        if project_root ~= nil then
          opts.cwd = project_root
        end
        if style == "ivy" then
          opts = require("telescope.themes").get_ivy(opts)
        end
        require("telescope.builtin")[picker](opts)
      end
      return {

        {
          "<leader>b",
          "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown({previewer = false}))<cr>",
          desc = "Buffers",
        },
        {
          "<leader>f",
          function()
            telescope_project_root("find_files")
          end,
          desc = "Find files",
        },
        {
          "<leader>F",
          function()
            telescope_project_root("live_grep", {}, "ivy")
          end,
          desc = "Search Text",
        },
        { "<leader>go", "<cmd>Telescope git_status<cr>",   desc = "Open changed file" },
        { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
        { "<leader>gc", "<cmd>Telescope git_commits<cr>",  desc = "Checkout commit" },
        {
          "<leader>gC",
          "<cmd>Telescope git_bcommits<cr>",
          desc = "Checkout commit(for current file)",
        },
        {
          "<leader>ld",
          "<cmd>Telescope diagnostics bufnr=0<cr>",
          desc = "Document Diagnostics",
        },
        { "<leader>lw", "<cmd>Telescope diagnostics<cr>",          desc = "Workspace Diagnostics" },
        { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
        {
          "<leader>lS",
          "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
          desc = "Workspace Symbols",
        },
        { "<leader>sb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
        { "<leader>sc", "<cmd>Telescope colorscheme<cr>",  desc = "Colorscheme" },
        { "<leader>sf", "<cmd>Telescope find_files<cr>",   desc = "Find File" },
        { "<leader>sh", "<cmd>Telescope help_tags<cr>",    desc = "Find Help" },
        { "<leader>sH", "<cmd>Telescope highlights<cr>",   desc = "Find highlight groups" },
        { "<leader>sM", "<cmd>Telescope man_pages<cr>",    desc = "Man Pages" },
        { "<leader>sr", "<cmd>Telescope oldfiles<cr>",     desc = "Open Recent File" },
        { "<leader>sR", "<cmd>Telescope resume<cr>",       desc = "Resume" },
        -- { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers" },
        { "<leader>st", "<cmd>Telescope live_grep<cr>",    desc = "Text" },
        { "<leader>sk", "<cmd>Telescope keymaps<cr>",      desc = "Keymaps" },
        { "<leader>sC", "<cmd>Telescope commands<cr>",     desc = "Commands" },
        { "<leader>sl", "<cmd>Telescope resume<cr>",       desc = "Resume last search" },
        {
          "<leader>sp",
          "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
          desc = "Colorscheme with Preview",
        },
      }
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
    config = function(_, opts)
      if vim.g.neovide ~= nil then
        opts.transparent = false
      end
      require("nord").setup(opts)
      vim.api.nvim_create_autocmd("Colorscheme", {
        pattern = { "nord" },
        callback = function()
          vim.cmd([[
            hi @markup.heading.1.markdown guifg=#D08770
            hi RenderMarkdownH1Bg guifg=#D08770 guibg=#3d3c44
            hi @markup.heading.5.markdown guifg=#EBCB8B
            hi RenderMarkdownH5Bg guifg=#EBCB8B guibg=#3f4247
            hi @markup.heading.3.markdown guifg=#A3BE8C
            hi RenderMarkdownH3Bg guifg=#A3BE8C guibg=#394147
            hi @markup.heading.2.markdown guifg=#81A1C1
            hi RenderMarkdownH2Bg guifg=#81A1C1 guibg=#363e4c
            hi @markup.heading.4.markdown guifg=#B48EAD
            hi RenderMarkdownH4Bg guifg=#B48EAD guibg=#3a3c4a
            hi @markup.heading.6.markdown guifg=#D8DEE9
            hi RenderMarkdownH6Bg guifg=#D8DEE9 guibg=#3d434f
            hi! link NoiceLspProgressTitle @comment
            ]])
        end,
      })
      vim.cmd("colorscheme nord")
    end,
    opts = {
      transparent = true,
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
    keys = {
      {
        "<leader>gj",
        "<cmd>lua require('gitsigns').nav_hunk('next', {navigation_message = false})<cr>",
        desc = "Next Hunk",
      },
      {
        "<leader>gk",
        "<cmd>lua require('gitsigns').nav_hunk('prev', {navigation_message = false})<cr>",
        desc = "Prev Hunk",
      },
      { "<leader>gl", "<cmd>lua require('gitsigns').blame_line()<cr>",            desc = "Blame" },
      { "<leader>gL", "<cmd>lua require('gitsigns').blame_line({full=true})<cr>", desc = "Blame Line (full)" },
      { "<leader>gp", "<cmd>lua require('gitsigns').preview_hunk()<cr>",          desc = "Preview Hunk" },
      { "<leader>gr", "<cmd>lua require('gitsigns').reset_hunk()<cr>",            desc = "Reset Hunk" },
      { "<leader>gR", "<cmd>lua require('gitsigns').reset_buffer()<cr>",          desc = "Reset Buffer" },
      { "<leader>gs", "<cmd>lua require('gitsigns').stage_hunk()<cr>",            desc = "Stage Hunk" },
      {
        "<leader>gu",
        "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>",
        desc = "Undo Stage Hunk",
      },
      { "<leader>bd", "<cmd>Gitsigns diffthis HEAD<cr>", desc = "Git Diff" },
    },
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
