return {
  {
    "norcalli/nvim-colorizer.lua",
    opts = {},
    event = "User FileOpened",
  },
  {
    "folke/todo-comments.nvim",
    opts = {},
    event = "User FileOpened",
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
    event = "User FileOpened",
  },
  {
    "stevearc/dressing.nvim",
    event = "VimEnter",
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("config.lualine").setup()
    end,
    event = "VimEnter",
  },
  {
    "SmiteshP/nvim-navic",
    config = function()
      require("config.breadcrumbs").setup()
    end,
    event = "User FileOpened",
  },
  {
    "akinsho/bufferline.nvim",
    config = function()
      require("config.bufferline").setup()
    end,
    branch = "main",
    event = "User FileOpened",
  },
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss All Notifications",
      },
    },
    opts = {
      stages = "static",
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    init = function()
      -- when noice is not enabled, install notify on VeryLazy
      if not require("util.plugins").has("noice.nvim") then
        require("util.plugins").on_very_lazy(function()
          vim.notify = require("notify")
        end)
      end
    end,
  },
  {
    "folke/noice.nvim",
    event = "VimEnter",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      views = {
        mini = {
          win_options = {
            winblend = 0,
          },
        },
      },
    },
    keys = {
      -- { "<leader>sn", "", desc = "+noice"},
      {
        "<S-Enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = "c",
        desc = "Redirect Cmdline",
      },
      -- { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      -- { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      -- { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      -- { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
      -- { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
      {
        "<c-f>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<c-f>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Forward",
        mode = { "i", "n", "s" },
      },
      {
        "<c-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-b>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Backward",
        mode = { "i", "n", "s" },
      },
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
  },
  {
    "3rd/image.nvim",
    dependencies = {
      "kiyoon/magick.nvim",
    },
    opts = {
      integrations = {
        markdown = {
          clear_in_insert_mode = true,
          only_render_image_at_cursor = true,
          resolve_image_path = function(document_path, image_path, fallback)
            local direct_path = vim.fs.joinpath(document_path, image_path)
            if vim.fn.filereadable(direct_path) == 1 then
              return direct_path
            end
            local attachments_path =
              vim.fs.joinpath(document_path:match("(.*)/"), "attachments", image_path:match("[^#|]+"))
            if vim.fn.filereadable(attachments_path) == 1 then
              return attachments_path
            end
            return fallback(document_path, image_path)
          end,
        },
      },
    },
    ft = "markdown",
  },
}
