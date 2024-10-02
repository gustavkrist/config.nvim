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
if vim.g.vscode == 1 then
  vim.cmd([[execute "source " . $HOME . "/.config/nvim/vscode/vscode.vim"]])
  dofile(os.getenv("HOME") .. "/.config/nvim/vscode/plugins.lua")
else
  require("config.options")
  require("config.keymap")
  require("config.autocommands")
  require("config.lsp")
  require("config.lazy")
  if vim.g.neovide then
    require("config.neovide")
  end
  if require("util.firenvim")() then
    require("config.firenvim")
  end
end
