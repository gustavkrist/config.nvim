local palette = require("nord.colors").palette
local M = {}

function M.make_theme_transparent(theme, swap_fg_bg)
  local template = {}
  for mode, mode_table in pairs(theme) do
    template[mode] = template[mode] or {}
    for section, section_table in pairs(mode_table) do
      if vim.tbl_contains({"b", "c"}, section) or not swap_fg_bg then
        template[mode][section] = {fg = section_table.fg, bg = "NONE", gui = section_table.gui }
      else
        template[mode][section] = { fg = section_table.bg, bg = "NONE" }
      end
    end
  end
  return template
end

function M.get_theme(name)
  local status_ok, _ = pcall(require, "lualine")
  if not status_ok then
    return
  end
  local theme_supported, template = pcall(function()
    return require("lualine.utils.loader").load_theme(name)
  end)
  return theme_supported, template
end

function M.load_template(name, transparent, swap_fg_bg)
  local status_ok, _ = pcall(require, "lualine")
  if not status_ok then
    return
  end
  local theme_supported, template = M.get_theme(name)
  if theme_supported and template then
    if transparent == nil or transparent then
      template = M.make_theme_transparent(template, swap_fg_bg == nil or swap_fg_bg)
    end
    require("lualine").setup({ options = { theme = template } })
  end
end

function M.load_lualine_custom_nord()
  require("lualine").setup({
    options = {
      theme = {
        normal = {
          a = { fg = palette.frost.ice, bg = "NONE" },
          b = { fg = palette.snow_storm.brighter, bg = "NONE" },
          c = { fg = palette.snow_storm.brighter, bg = "NONE" },
          x = { fg = palette.snow_storm.brighter, bg = "NONE" },
          y = { fg = palette.aurora.purple, bg = "NONE" },
          z = { fg = palette.frost.ice, bg = "NONE" },
        },
        insert = {
          a = { fg = palette.snow_storm.origin, bg = "NONE" },
        },
        visual = {
          a = { fg = palette.frost.polar_water, bg = "NONE" },
        },
        command = {
          a = { fg = palette.aurora.purple },
        },
        inactive = {
          a = { fg = require("nord.utils").make_global_bg(), bg = "NONE" },
          b = { fg = require("nord.utils").make_global_bg(), bg = "NONE" },
          c = { fg = palette.polar_night.bright, bg = "NONE" },
        },
      }
    }
  })
end

return M
