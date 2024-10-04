return {
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
    lazy = true,
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
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    keys = function()
      local function grug_project_root()
        local grug = require("grug-far")
        -- local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            paths = require("util.root")(),
            -- filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end
      return {
        { "<leader>sg", grug_project_root, mode = { "n", "v" }, desc = "Search and Replace" },
      }
    end,
    cmd = "GrugFar",
  },
  {
    "almo7aya/openingh.nvim",
    config = function()
      require("util.plugins").on_load("which-key.nvim", function()
        require("which-key").add({ "<leader>og", group = "Open in GitHub..." })
      end)
    end,
    keys = function()
      local openingh = require("util.git").run_openingh_with_picked_ref
      return {
        { "<leader>ogr", "<cmd>OpenInGHRepo<cr>", desc = "Open repo in GitHub" },
        {
          "<leader>ogf",
          function()
            openingh("OpenInGHFile")
          end,
          mode = "n",
          desc = "Open file in GitHub",
        },
        {
          "<leader>ogl",
          function()
            openingh("OpenInGHFileLines")
          end,
          mode = "n",
          desc = "Open line(s) in GitHub",
        },
        {
          "<leader>ogl",
          function()
            openingh("OpenInGHFileLines", "v")
          end,
          mode = "v",
          desc = "Open line(s) in GitHub",
        },
      }
    end,
    cmd = { "OpenInGHRepo", "OpenInGHFile", "OpenInGHFileLines" },
  },
  {
    "windwp/nvim-ts-autotag",
    opts = {},
    ft = { "html", "vue" },
  },
}
