-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local firenvim = require("util.firenvim").get

require("lazy").setup({
  spec = {
    { import = "plugins.base" },
    { import = "plugins.completion" },
    { import = "plugins.filetypes" },
    { import = "plugins.mini" },
    { import = "plugins.treesitter" },
    { import = "plugins.utility" },
    { import = "plugins.lsp",               cond = not firenvim() },
    { import = "plugins.lualine",           cond = not firenvim() },
    { import = "plugins.telescope-grapple", cond = not firenvim() },
    { import = "plugins.visual",            cond = not firenvim() },
    { "glacambre/firenvim",                 build = ":call firenvim#install(0)", cond = firenvim() }
  },
  install = { colorscheme = { "nord" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
