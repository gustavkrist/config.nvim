return {
  {
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
      local ai = require("mini.ai")
      local opts = {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          i = require("config.mini").ai_indent, -- indent
          g = require("config.mini").ai_buffer, -- buffer
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
      ai.setup(opts)
      require("util.plugins").on_load("which-key.nvim", function()
        vim.schedule(function()
          require("config.mini").ai_whichkey(opts)
        end)
      end)
      require("mini.cursorword").setup()
      require("mini.files").setup({
        windows = {
          preview = true,
          width_preview = 30,
        },
        options = {
          use_as_default_explorer = true,
        },
      })
      -- require("mini.notify").setup({ lsp_progress = { enable = false } })
      require("mini.sessions").setup()
      require("mini.splitjoin").setup()
      require("mini.starter").setup()
      require("mini.trailspace").setup()
    end,
    event = "VimEnter",
  },
  { "echasnovski/mini.icons", lazy = true },
}
