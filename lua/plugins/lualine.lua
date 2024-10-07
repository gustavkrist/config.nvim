return {
  {
    "nvim-lualine/lualine.nvim",
    cond = function() return not require("util.firenvim").get() end,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "gbprod/nord.nvim",
    },
    config = function(_, opts)
      if #vim.api.nvim_list_uis() == 0 then
        -- Headless mode, don't setup lualine
        return
      end
      require("lualine").setup(opts)
    end,
    opts = function()
      local palette = require("nord.colors").palette
      local icons = require("util.icons")

      local function hide_in_width()
        return vim.o.columns > 100
      end

      local function env_cleanup(venv)
        if string.find(venv, "/") then
          local final_venv = venv
          for w in venv:gmatch("([^/]+)") do
            final_venv = w
          end
          venv = final_venv
        end
        return venv
      end

      local colors = {
        green = palette.aurora.green,
        red = palette.aurora.red,
        yellow = palette.aurora.yellow,
      }

      local function diff_source()
        local gitsigns = vim.b.gitsigns_status_dict
        if gitsigns then
          return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
          }
        end
      end

      local branch = icons.git.Branch

      local components = {
        mode = {
          function()
            return " " .. icons.ui.Target .. " "
          end,
          padding = { left = 0, right = 0 },
          color = {},
          cond = nil,
        },
        branch = {
          "b:gitsigns_head",
          icon = branch,
          color = { gui = "bold" },
        },
        filename = {
          "filename",
          color = {},
          cond = nil,
        },
        diff = {
          "diff",
          source = diff_source,
          symbols = {
            added = icons.git.LineAdded .. " ",
            modified = icons.git.LineModified .. " ",
            removed = icons.git.LineRemoved .. " ",
          },
          padding = { left = 2, right = 1 },
          diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.yellow },
            removed = { fg = colors.red },
          },
          cond = nil,
        },
        python_env = {
          function()
            if vim.bo.filetype == "python" then
              local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
              if venv then
                local py_icon, _ = require("nvim-web-devicons").get_icon(".py")
                return string.format(" " .. py_icon .. " (%s)", env_cleanup(venv))
              end
            end
            return ""
          end,
          color = { fg = colors.green },
          cond = hide_in_width,
        },
        diagnostics = {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = {
            error = icons.diagnostics.BoldError .. " ",
            warn = icons.diagnostics.BoldWarning .. " ",
            info = icons.diagnostics.BoldInformation .. " ",
            hint = icons.diagnostics.BoldHint .. " ",
          },
          -- cond = hide_in_width,
        },
        treesitter = {
          function()
            return icons.ui.Tree
          end,
          color = function()
            local buf = vim.api.nvim_get_current_buf()
            local ts = vim.treesitter.highlighter.active[buf]
            return { fg = ts and not vim.tbl_isempty(ts) and colors.green or colors.red }
          end,
          cond = hide_in_width,
        },
        lsp = {
          function()
            local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
            local buf_client_names = {}
            local copilot_active = false

            -- add formatters and linters
            local running_formatters = require("conform").list_formatters_for_buffer(0)
            vim.list_extend(buf_client_names, running_formatters)

            local running_linters = require("lint").get_running(0)
            vim.list_extend(buf_client_names, running_linters)

            if (#buf_clients + #buf_client_names) == 0 then
              return "LSP Inactive"
            end

            -- add client
            for _, client in pairs(buf_clients) do
              if client.name ~= "copilot" then
                table.insert(buf_client_names, client.name)
              end

              if client.name == "copilot" then
                copilot_active = true
              end
            end

            local unique_client_names = table.concat(buf_client_names, ", ")
            local language_servers = string.format("[%s]", unique_client_names)

            if copilot_active then
              language_servers = language_servers .. "%#SLCopilot#" .. " " .. icons.git.Octoface .. "%*"
            end

            return language_servers
          end,
          color = { gui = "bold" },
          cond = hide_in_width,
        },
        location = { "location" },
        progress = {
          "progress",
          fmt = function()
            return "%P/%L"
          end,
          color = {},
        },

        spaces = {
          function()
            local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", { buf = 0 })
            return icons.ui.Tab .. " " .. shiftwidth
          end,
          padding = 1,
        },
        encoding = {
          "o:encoding",
          fmt = string.upper,
          color = {},
          cond = hide_in_width,
        },
        filetype = { "filetype", cond = nil, padding = { left = 1, right = 1 } },
        scrollbar = {
          function()
            local current_line = vim.fn.line(".")
            local total_lines = vim.fn.line("$")
            local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
            local line_ratio = current_line / total_lines
            local index = math.ceil(line_ratio * #chars)
            return chars[index]
          end,
          padding = { left = 0, right = 0 },
          color = {},
          cond = nil,
        },
      }
      return {
        options = {
          theme = "auto",
          globalstatus = true,
          icons_enabled = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { "ministarter" },
        },
        sections = {
          lualine_a = {
            -- components.mode,
          },
          lualine_b = {
            components.branch,
            "grapple",
          },
          lualine_c = {
            components.diff,
            components.python_env,
          },
          lualine_x = {
            components.diagnostics,
            components.lsp,
            components.spaces,
            components.filetype,
          },
          lualine_y = { components.location },
          lualine_z = {
            components.progress,
            components.scrollbar,
          },
        },
        inactive_sections = {
          lualine_a = {
            -- components.mode,
          },
          lualine_b = {
            components.branch,
          },
          lualine_c = {
            components.diff,
            components.python_env,
          },
          lualine_x = {
            components.diagnostics,
            components.lsp,
            components.spaces,
            components.filetype,
          },
          lualine_y = { components.location },
          lualine_z = {
            components.progress,
            components.scrollbar,
          },
        },
        tabline = {
          lualine_a = {
            {
              "filename",
              path = 1,
              newfile_status = true,
              shorting_target = 90,
              cond = function()
                return not vim.tbl_contains({
                  "",
                  "DressingSelect",
                  "Jaq",
                  "NvimTree",
                  "Outline",
                  "TelescopePrompt",
                  "Trouble",
                  "alpha",
                  "checkhealth",
                  "dap-repl",
                  "dap-terminal",
                  "dapui_console",
                  "dapui_hover",
                  "dashboard",
                  "grapple",
                  "harpoon",
                  "help",
                  "lab",
                  "lazy",
                  "lir",
                  "mason",
                  "minifiles",
                  "ministarter",
                  "neo-tree",
                  "neogitstatus",
                  "neotest-summary",
                  "noice",
                  "notify",
                  "qf",
                  "spectre_panel",
                  "startify",
                  "toggleterm",
                }, vim.api.nvim_get_option_value("filetype", {}))
              end,
            },
          },
          lualine_x = {
            -- HACK: Removed `%*` from the end of the grapple-line output so the highlight group is not cut off
            --       which gets rid of an incorrecly highlighted cell
            function() return require("grapple-line").lualine():match("^(.*)%%%*$") or "" end,
          },
          lualine_z = {
            {
              "tabs",
              cond = function()
                return #vim.api.nvim_list_tabpages() > 1
              end,
            },
          },
        },
        winbar = {
          lualine_a = {
            { require("util.navic").get_winbar },
          },
        },
        inactive_winbar = {
          lualine_a = {
            { require("util.navic").get_winbar },
          },
        },
        extensions = {},
      }
    end,
    event = "VeryLazy",
  },
}
