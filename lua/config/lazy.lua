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
    { import = "plugins.colorschemes" },
    { import = "plugins.completion" },
    { import = "plugins.filetypes" },
    { import = "plugins.lsp" },
    { import = "plugins.lualine" },
    { import = "plugins.mini" },
    { import = "plugins.telescope-grapple" },
    { import = "plugins.treesitter" },
    { import = "plugins.utility" },
    { import = "plugins.visual" },
    { "glacambre/firenvim",                build = ":call firenvim#install(0)", cond = firenvim() }
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
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Open Lazy" })
