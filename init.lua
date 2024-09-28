-- if vim.g.started_by_fnvim ~= 1 then
--     print('nvim')
-- else
--     dofile(os.getenv("LUNARVIM_RUNTIME_DIR") .. "/lvim/init.lua")
-- end

if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
  }
end
if vim.g.started_by_firenvim == true then
  require("user.plugins")
  require("user.options")
  require("user.keymap")
  require("user.colorscheme")
  require("user.cmp")
  require("user.lsp")
  require("user.treesitter")
  require("user.autopairs")
  require("user.comment")
  require("user.toggleterm_settings")
  require("user.impatient")
  require("user.indentline")
  require("user.whichkey_map")
  require("user.autocommands")
  require("user.lualine")
  vim.cmd([[let b:path = stdpath("config") . "/lua/user/firenvim.vim"|execute "source " . b:path]])
  vim.cmd([[let b:path = stdpath("config") . "/lua/user/togglewrap.vim"|execute "source " . b:path]])
elseif vim.g.vscode == 1 then
  vim.cmd([[execute "source " . $HOME . "/.config/nvim/vscode/vscode.vim"]])
  dofile(os.getenv("HOME") .. "/.config/nvim/vscode/plugins.lua")
else
  -- dofile(os.getenv("LUNARVIM_RUNTIME_DIR") .. "/lvim/init.lua")
  require("config.options")
  require("config.keymap")
  require("config.autocommands")
  require("config.lsp")
  require("config.lazy")
  if vim.g.neovide then
    require("config.neovide")
  end
end
