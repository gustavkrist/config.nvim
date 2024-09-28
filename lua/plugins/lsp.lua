return {
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    dependencies = {
      "mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local vue_language_server_path = require("mason-registry").get_package("vue-language-server"):get_install_path()
          .. "/node_modules/@vue/language-server"

      local servers = {
        bashls = true,
        fsautocomplete = true,
        hls = {
          manual_install = true
        },
        jsonls = true,
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
          on_init = function(client)
            local path = client.workspace_folders[1].name
            if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
              client.config.settings = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                runtime = {
                  version = "LuaJIT",
                },
                workspace = {
                  library = { vim.env.VIMRUNTIME },
                },
              })
              client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
            end
            return true
          end,
        },
        pyright = true,
        texlab = true,
        ts_ls = {
          init_options = {
            plugins = {
              {
                name = "@vue/typescript-plugin",
                location = vue_language_server_path,
                languages = { "vue" },
              },
            },
          },
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          on_attach = function(client, bufnr)
            if vim.api.nvim_get_option_value("filetype", { buf = bufnr }) ~= "vue" then
              require("nvim-navic").attach(client, bufnr)
            end
          end,
        },
        vimls = true,
        volar = true,
        yamlls = true,
      }

      -- From https://github.com/tjdevries/config.nvim/blob/37c9356fd40a8d3589638c8d16a6a6b1274c40ca/lua/custom/plugins/lsp.lua
      local servers_to_install = vim.tbl_filter(function(key)
        local t = servers[key]
        if type(t) == "table" then
          return not t.manual_install
        else
          return t
        end
      end, vim.tbl_keys(servers))

      require("mason-tool-installer").setup({ ensure_installed = servers_to_install })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      for name, config in pairs(servers) do
        if config == true then
          config = {}
        end
        config = vim.tbl_deep_extend("force", {}, {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            require("nvim-navic").attach(client, bufnr)
          end,
        }, config)

        lspconfig[name].setup(config)
      end
    end
  },
  {
    "williamboman/mason.nvim",
    opts = {},
    build = function()
      pcall(function()
        require("mason-registry").refresh()
      end)
    end,
    keys = {
      { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" },
    }
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {},
    dependencies = "mason.nvim",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>",      desc = "Decrement Selection", mode = "x" },
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
        sync_install = false,    -- install languages synchronously (only applied to `ensure_installed`)
        ignore_install = { "" }, -- List of parsers to ignore installing
        autopairs = {
          enable = true,
        },
        highlight = {
          enable = true,    -- false will disable the whole extension
          disable = { "" }, -- list of language that will be disabled
          additional_vim_regex_highlighting = false,
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
        indent = { enable = true }, disable = { "yaml", "python" },
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
  {
    "stevearc/conform.nvim",
    config = function()
      local opts = {
        default_format_opts = {
          timeout_ms = 3000,
          async = false,           -- not recommended to change
          quiet = false,           -- not recommended to change
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
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufRead" }, {
        pattern = { "*.js", "*.py", "*.vue" },
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
  {
    "SmiteshP/nvim-navic",
    config = function(_, opts)
      require("util.navic").create_winbar()
      require("nvim-navic").setup(opts)
    end,
    opts = function()
      local icons = require("util.icons").kind
      return {
        icons = {
          Array = icons.Array .. " ",
          Boolean = icons.Boolean .. " ",
          Class = icons.Class .. " ",
          Color = icons.Color .. " ",
          Constant = icons.Constant .. " ",
          Constructor = icons.Constructor .. " ",
          Enum = icons.Enum .. " ",
          EnumMember = icons.EnumMember .. " ",
          Event = icons.Event .. " ",
          Field = icons.Field .. " ",
          File = icons.File .. " ",
          Folder = icons.Folder .. " ",
          Function = icons.Function .. " ",
          Interface = icons.Interface .. " ",
          Key = icons.Key .. " ",
          Keyword = icons.Keyword .. " ",
          Method = icons.Method .. " ",
          Module = icons.Module .. " ",
          Namespace = icons.Namespace .. " ",
          Null = icons.Null .. " ",
          Number = icons.Number .. " ",
          Object = icons.Object .. " ",
          Operator = icons.Operator .. " ",
          Package = icons.Package .. " ",
          Property = icons.Property .. " ",
          Reference = icons.Reference .. " ",
          Snippet = icons.Snippet .. " ",
          String = icons.String .. " ",
          Struct = icons.Struct .. " ",
          Text = icons.Text .. " ",
          TypeParameter = icons.TypeParameter .. " ",
          Unit = icons.Unit .. " ",
          Value = icons.Value .. " ",
          Variable = icons.Variable .. " ",
        },
        highlight = true,
        separator = " " .. require("util.icons").ui.ChevronRight .. " ",
        depth_limit = 0,
        depth_limit_indicator = "..",
      }
    end,
    event = "User FileOpened",
  },
}
