local M = {}
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
    style = "lvim",
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
