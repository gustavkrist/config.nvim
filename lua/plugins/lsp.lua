return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<BS>", desc = "Decrement Selection", mode = "x" },
        { "<c-space>", desc = "Increment Selection", mode = { "x", "n" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    dependencies = {
      "mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {},
    build = function()
      pcall(function()
        require("mason-registry").refresh()
      end)
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {},
    dependencies = "mason.nvim",
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    version = "v2.*",
    build = "make install_jsregexp",
    event = "InsertEnter",
  },
  { "rafamadriz/friendly-snippets", lazy = true },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    config = function()
      local configs = require("nvim-treesitter.configs")
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

      -- Setup https://github.com/ionide/tree-sitter-fsharp
      parser_config.fsharp = {
        install_info = {
          url = "https://github.com/ionide/tree-sitter-fsharp",
          branch = "main",
          files = { "src/scanner.c", "src/parser.c" },
          location = "fsharp",
        },
        requires_generate_from_grammar = false,
        filetype = "fsharp",
      }

      configs.setup({
        ensure_installed = {
          "bash",
          "c",
          "diff",
          "fsharp",
          "html",
          "javascript",
          "jsdoc",
          "json",
          "jsonc",
          "latex",
          "lua",
          "luadoc",
          "luap",
          "markdown",
          "markdown_inline",
          "printf",
          "python",
          "query",
          "regex",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "vue",
          "xml",
          "yaml",
        },
        sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
        ignore_install = { "" }, -- List of parsers to ignore installing
        autopairs = {
          enable = true,
        },
        highlight = {
          enable = true, -- false will disable the whole extension
          disable = { "" }, -- list of language that will be disabled
          additional_vim_regex_highlighting = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        indent = { enable = true }, --, disable = { "yaml", "python" } },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        textobjects = {
          move = {
            enable = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]a"] = "@parameter.inner",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
              ["]A"] = "@parameter.inner",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.inner",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
              ["[A"] = "@parameter.inner",
            },
          },
        },
      })
    end,
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    cmd = {
      "TSInstall",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
      "TSInstallInfo",
      "TSInstallSync",
      "TSInstallFromGrammar",
    },
    event = "User FileOpened",
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("config.cmp").setup()
    end,
    event = { "InsertEnter", "CmdlineEnter" },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "User FileOpened",
    config = function()
      -- If treesitter is already loaded, we need to run config again for textobjects
      if require("util.plugins").is_loaded("nvim-treesitter") then
        require("nvim-treesitter.configs").setup({
          textobjects = {
            move = {
              enable = true,
              goto_next_start = {
                ["]f"] = "@function.outer",
                ["]c"] = "@class.outer",
                ["]a"] = "@parameter.inner",
              },
              goto_next_end = {
                ["]F"] = "@function.outer",
                ["]C"] = "@class.outer",
                ["]A"] = "@parameter.inner",
              },
              goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
                ["[a"] = "@parameter.inner",
              },
              goto_previous_end = {
                ["[F"] = "@function.outer",
                ["[C"] = "@class.outer",
                ["[A"] = "@parameter.inner",
              },
            },
          },
        })
      end

      -- When in diff mode, we want to use the default
      -- vim text objects c & C instead of the treesitter ones.
      local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
      local configs = require("nvim-treesitter.configs")
      for name, fn in pairs(move) do
        if name:find("goto") == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find("[%]%[][cC]") then
                  vim.cmd("normal! " .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },
  { "hrsh7th/cmp-nvim-lsp", lazy = true },
  { "saadparwaiz1/cmp_luasnip", lazy = true },
  { "hrsh7th/cmp-buffer", lazy = true },
  { "hrsh7th/cmp-path", lazy = true },
  { "hrsh7th/cmp-nvim-lua", lazy = true },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    lazy = true,
    cmd = { "VenvSelect" },
    branch = "regexp", -- This is the regexp branch, use this for the new version
    opts = {
      settings = {
        search = {
          workspace = false,
          file = false,
          pipx = false,
          cwd = false,
          poetry = false,
          hatch = false,
          virtualenvs = false,
          miniconda_envs = false,
          miniconda_base = false,
          pipenv = false,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    config = function()
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
          lsp_format = "fallback", -- not recommended to change
        },
        formatters = {
          injected = {
            options = {
              ignore_errors = true,
              lang_to_ext = {
                bash = "sh",
                c_sharp = "cs",
                fsharp = "fs",
                javascript = "js",
                latex = "tex",
                markdown = "md",
                python = "py",
              },
            },
          },
          pyupgrade = {
            command = "pyupgrade",
            exit_codes = { 0, 1 },
            stdin = false,
            args = { "$FILENAME" },
            cwd = require("conform.util").root_file({ "pyproject.toml" }),
          },
        },
        formatters_by_ft = {
          fsharp = { "fantomas" },
          lua = { "stylua" },
          markdown = { "injected" },
          python = { "black", "isort", "pyupgrade" },
          sh = { "shfmt" },
          vue = { "eslint_d" },
        },
      }
      require("conform").setup(opts)
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>lF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
      {
        "<leader>lf",
        function()
          local buf = vim.api.nvim_get_current_buf()
          require("conform").format({ bufnr = buf })
        end,
        mode = { "n", "v" },
        desc = "Format",
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      local linters_by_ft = {
        lua = { "stylua" },
        python = { "flake8", "mypy" },
        vue = { "eslint" },
      }
      local executable_linters = {}
      for filetype, linters in pairs(linters_by_ft) do
        for _, linter in ipairs(linters) do
          if vim.fn.executable(linter) == 1 then
            if executable_linters[filetype] == nil then
              executable_linters[filetype] = {}
            end
            table.insert(executable_linters[filetype], linter)
          end
        end
      end
      require("lint").linters_by_ft = executable_linters
    end,
  },
  {
    "jmbuhr/otter.nvim",
    opts = {},
    version = "*",
  },
}
