local M = {}

local colors = require("nord.colors").palette

M.setup = function()
  if #vim.api.nvim_list_uis() == 0 then
    -- Headless mode, don't setup lualine
    return
  end
  local components = require("config.lualine.components")

  local status_ok, lualine = pcall(require, "lualine")
  if not status_ok then
    return
  end

  local opts = {
    options = {
      theme = {
        normal = {
          a = { fg = colors.frost.ice, bg = "NONE" },
          b = { fg = colors.snow_storm.brighter, bg = "NONE" },
          c = { fg = colors.snow_storm.brighter, bg = "NONE" },
          x = { fg = colors.snow_storm.brighter, bg = "NONE" },
          y = { fg = colors.aurora.purple, bg = "NONE" },
          z = { fg = colors.frost.ice, bg = "NONE" },
        },
        insert = {
          a = { fg = colors.snow_storm.origin, bg = "NONE" },
        },
        visual = {
          a = { fg = colors.frost.polar_water, bg = "NONE" },
        },
        command = {
          a = { fg = colors.aurora.purple },
        },
        inactive = {
          a = { fg = require("nord.utils").make_global_bg(), bg = "NONE" },
          b = { fg = require("nord.utils").make_global_bg(), bg = "NONE" },
          c = { fg = colors.polar_night.bright, bg = "NONE" },
        }
      },
      globalstatus = true,
      icons_enabled = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { "ministarter" },
    },
    sections = {
      lualine_a = {
        components.mode,
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
      },
    },
    inactive_sections = {
      lualine_a = {
        components.mode,
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
      },
    },
    tabline = {},
    extensions = {},
  }
  local color_template = vim.g.colors_name
  local theme_supported, template = pcall(function()
    require("lualine.utils.loader").load_theme(color_template)
  end)
  if theme_supported and template then
    opts.options.theme = color_template
  end
  lualine.setup(opts)
end

return M
