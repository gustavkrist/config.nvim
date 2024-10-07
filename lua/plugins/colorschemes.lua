return {
  {
    "gbprod/nord.nvim",
    config = function(_, opts)
      if vim.g.neovide ~= nil or require("util.firenvim")() then
        opts.transparent = false
      end
      require("nord").setup(opts)
      vim.api.nvim_create_autocmd("Colorscheme", {
        pattern = { "nord" },
        callback = function()
          vim.cmd([[
            hi! link NoiceLspProgressTitle @comment
            hi NavicSeparator guibg=NONE
            ]])
          require("util.wezterm").set_term_background("#D8DEE9", "#2E3440", "#D8DEE9")
          require("util.lualine").load_lualine_custom_nord()
        end,
      })
      vim.cmd("colorscheme nord")
      require("util.lualine").load_lualine_custom_nord()
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
    "folke/tokyonight.nvim",
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.api.nvim_create_autocmd("Colorscheme", {
        pattern = { "tokyonight" },
        callback = function()
          vim.cmd([[
            hi! link NoiceLspProgressTitle @comment
            hi NavicSeparator guibg=NONE
            ]])
          require("util.wezterm").set_term_background("#c0caf5", "#24283b", "#c0caf5")
          require("util.lualine").load_template("tokyonight")
        end,
      })
    end,
    opts = {
      transparent = true,
    },
  },
  {
    "widatama/vim-phoenix",
    init = function()
      vim.api.nvim_create_autocmd("Colorscheme", {
        pattern = { "phoenix" },
        callback = function()
          vim.cmd([[
            hi Normal guibg=NONE
            hi! link NoiceLspProgressTitle @comment
            hi NavicSeparator guibg=NONE
            ]])
          require("util.wezterm").set_term_background("#CCCCCC", "#191919", "#EFEFEF")
        end,
      })
    end
  },
  {
    "kxzk/skull-vim",
    init = function()
      vim.api.nvim_create_autocmd("Colorscheme", {
        pattern = { "skull" },
        callback = function()
          vim.cmd([[
            hi Normal guibg=NONE
            hi! link NoiceLspProgressTitle @comment
            hi NavicSeparator guibg=NONE
            ]])
          require("util.wezterm").set_term_background("#CCCCCC", "#222222", "#A0A0A0")
        end,
      })
    end
  },
  {
    "kvrohit/rasmus.nvim",
    init = function()
      vim.g.rasmus_transparent = true
      -- vim.g.rasmus_variant = "monochrome"
      vim.api.nvim_create_autocmd("Colorscheme", {
        pattern = { "rasmus" },
        callback = function()
          vim.cmd([[
            hi! link NoiceLspProgressTitle @comment
            hi NavicSeparator guibg=NONE
            ]])
          require("util.wezterm").set_term_background("#d1d1d1", "#1a1a19", "#7bb099")
        end,
      })
    end
  },
  {
    "gustavkrist/darkvoid.nvim",
    config = function(_, opts)
      require("darkvoid").setup(opts)
      vim.api.nvim_create_autocmd("Colorscheme", {
        pattern = { "darkvoid" },
        callback = function()
          vim.cmd([[
            hi! link NoiceLspProgressTitle @comment
            hi NavicSeparator guibg=NONE
            ]])
          require("util.wezterm").set_term_background("#c0c0c0", "#1c1c1c", "#bdfe58")
          require("util.lualine").load_template("darkvoid", true, false)
          -- require("lualine").setup({ options = { theme = "darkvoid" } })
        end,
      })
    end,
    opts = {
      transparent = true,
      glow = true,
      disabled_plugins = { "lualine" }
    },
  },
}
