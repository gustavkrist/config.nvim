local map = vim.keymap.set
return {
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
        require("which-key").add({ "<leader>og>", group = "Open in GitHub..." })
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
            openingh(":OpenInGHFileLines")
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
    event = "User FileOpened",
    opts = {},
  },
}
