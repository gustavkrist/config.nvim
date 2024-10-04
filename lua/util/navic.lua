local M = {}

local icons = require("util.icons").kind

local function isempty(s)
  return s == nil or s == ""
end

local winbar_filetype_exclude = {
  "",
  "DressingSelect",
  "Jaq",
  "NvimTree",
  "Outline",
  "Trouble",
  "alpha",
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
  "ministarter",
  "neo-tree",
  "neogitstatus",
  "neotest-summary",
  "noice",
  "notify",
  "spectre_panel",
  "startify",
  "toggleterm",
}

function M.get_filename()
  local filename = vim.fn.expand("%:t")
  local extension = vim.fn.expand("%:e")

  if not isempty(filename) then
    local file_icon, hl_group
    local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
    if devicons_ok then
      file_icon, hl_group = devicons.get_icon(filename, extension, { default = true })

      if isempty(file_icon) then
        file_icon = icons.File
      end
    else
      file_icon = ""
      hl_group = "Normal"
    end

    local buf_ft = vim.bo.filetype

    if buf_ft == "dapui_breakpoints" then
      file_icon = require("util.icons").ui.Bug
    end

    if buf_ft == "dapui_stacks" then
      file_icon = require("util.icons").ui.Stacks
    end

    if buf_ft == "dapui_scopes" then
      file_icon = require("util.icons").ui.Scopes
    end

    if buf_ft == "dapui_watches" then
      file_icon = require("util.icons").ui.Watches
    end

    local navic_text_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    vim.api.nvim_set_hl(0, "Winbar", { fg = navic_text_hl.fg })

    return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. " " .. "%#Winbar#" .. filename .. "%*"
  end
end

local get_gps = function()
  local status_gps_ok, gps = pcall(require, "nvim-navic")
  if not status_gps_ok then
    return ""
  end

  local status_ok, gps_location = pcall(gps.get_location, {})
  if not status_ok then
    return ""
  end

  if not gps.is_available() or gps_location == "error" then
    return ""
  end

  if not isempty(gps_location) then
    return "%#NavicSeparator#" .. require("util.icons").ui.ChevronRight .. "%* " .. gps_location
  else
    return ""
  end
end

local excludes = function()
  return vim.tbl_contains(winbar_filetype_exclude or {}, vim.bo.filetype)
end

function M.get_winbar()
  if excludes() then
    return
  end
  local value = M.get_filename()

  local gps_added = false
  if not isempty(value) then
    local gps_value = get_gps()
    value = value .. " " .. gps_value
    if not isempty(gps_value) then
      gps_added = true
    end
  end

  if not isempty(value) and vim.api.nvim_get_option_value("mod", { buf = 0 }) then
    local mod = "%#LspCodeLens#" .. require("util.icons").ui.Circle .. "%*"
    if gps_added then
      value = value .. " " .. mod
    else
      value = value .. mod
    end
  end

  local num_tabs = #vim.api.nvim_list_tabpages()

  if num_tabs > 1 and not isempty(value) then
    local tabpage_number = tostring(vim.api.nvim_tabpage_get_number(0))
    value = value .. "%=" .. tabpage_number .. "/" .. tostring(num_tabs)
  end
  return value
end

function M.set_winbar()
  local value = M.get_winbar()
  local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
  if not status_ok then
    return
  end
end

function M.create_winbar()
  vim.api.nvim_create_augroup("_winbar", {})
  vim.api.nvim_create_autocmd({
    "CursorHoldI",
    "CursorHold",
    "BufWinEnter",
    "BufFilePost",
    "InsertEnter",
    "BufWritePost",
    "TabClosed",
    "TabEnter",
  }, {
    group = "_winbar",
    callback = function()
      local status_ok, _ = pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_window")
      if not status_ok then
        M.set_winbar()
      end
    end,
  })
end

return M
