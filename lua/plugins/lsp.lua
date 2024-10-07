local no_firenvim = function() return not require("util.firenvim").get() end
return {
  {
    "neovim/nvim-lspconfig",
    cond = no_firenvim,
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

      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = ok and cmp_nvim_lsp.default_capabilities() or {}

      local servers = {
        bashls = true,
        fsautocomplete = true,
        hls = {
          manual_install = true
        },
        jsonls = true,
        lua_ls = true,
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
          capabilities = capabilities,
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
    cond = no_firenvim,
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
    cond = no_firenvim,
    opts = {},
    dependencies = "mason.nvim",
    lazy = false,
  },
  {
    "stevearc/conform.nvim",
    cond = no_firenvim,
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
    cond = no_firenvim,
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
    lazy = true,
  },
  {
    "SmiteshP/nvim-navic",
    cond = no_firenvim,
    config = function(_, opts)
      require("nvim-navic").setup(opts)
    end,
    opts = function()
      local function get_icon(kind)
        local icon, _, _ = require("mini.icons").get("lsp", kind)
        return icon .. " "
      end
      return {
        icons = {
          Array = get_icon("Array"),
          Boolean = get_icon("Boolean"),
          Class = get_icon("Class"),
          Color = get_icon("Color"),
          Constant = get_icon("Constant"),
          Constructor = get_icon("Constructor"),
          Enum = get_icon("Enum"),
          EnumMember = get_icon("EnumMember"),
          Event = get_icon("Event"),
          Field = get_icon("Field"),
          File = get_icon("File"),
          Folder = get_icon("Folder"),
          Function = get_icon("Function"),
          Interface = get_icon("Interface"),
          Key = get_icon("Key"),
          Keyword = get_icon("Keyword"),
          Method = get_icon("Method"),
          Module = get_icon("Module"),
          Namespace = get_icon("Namespace"),
          Null = get_icon("Null"),
          Number = get_icon("Number"),
          Object = get_icon("Object"),
          Operator = get_icon("Operator"),
          Package = get_icon("."),
          Property = get_icon("Property"),
          Reference = get_icon("Reference"),
          Snippet = get_icon("Snippet"),
          String = get_icon("String"),
          Struct = get_icon("Struct"),
          Text = get_icon("Text"),
          TypeParameter = get_icon("TypeParameter"),
          Unit = get_icon("Unit"),
          Value = get_icon("Value"),
          Variable = get_icon("Variable"),
        },
        highlight = true,
        separator = " " .. require("util.icons").ui.ChevronRight .. " ",
        depth_limit = 0,
        depth_limit_indicator = "..",
      }
    end,
    event = "VeryLazy",
  },
  { "justinsgithub/wezterm-types", lazy = true },
  {
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "wezterm-types", modes = { "wezterm" } },
        },
      },
    },
  },
  {
    cond = no_firenvim,
    "danymat/neogen",
    opts = {
      snippet_engine = "luasnip",
    },
    keys = {
      { "<leader>nc", "<cmd>lua require('neogen').generate({ type = 'class' })<cr>", desc = "Generate Annotations (Class)" },
      { "<leader>nf", "<cmd>lua require('neogen').generate({ type = 'func' })<cr>",  desc = "Generate Annotations (Function)" },
      { "<leader>nt", "<cmd>lua require('neogen').generate({ type = 'type' })<cr>",  desc = "Generate Annotations (Type)" },
      { "<leader>nF", "<cmd>lua require('neogen').generate({ type = 'file' })<cr>",  desc = "Generate Annotations (File)" },
    }
  },
}
