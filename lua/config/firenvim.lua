vim.o.guifont = "FiraCode Nerd Font:h14"
vim.o.cmdheight = 0
vim.g.firenvim_config = {
  globalSettings = {},
  localSettings = {
    [".*"] = {
      takeover = "never",
      cmdline = "neovim",
    },
  },
}
vim.keymap.set(
  "i",
  "<C-S-v>",
  "<C-o>:set paste<cr>a<c-r>+<cr><C-o>:set nopaste<cr>mi`[=`]`ia",
  { noremap = false, silent = true }
)
vim.keymap.set("!", "<C-S-v>", "<C-R>+", { noremap = true, silent = true })
vim.keymap.set("t", "<C-S-v>", "<C-\\><C-n>pi", { noremap = false, silent = true })
vim.keymap.set({ "v", "n" }, "<C-S-v>", '"+gP', { noremap = true, silent = true })
vim.api.nvim_create_autocmd({'UIEnter'}, {
    callback = function(event)
        local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
        if client ~= nil and client.name == "Firenvim" then
            vim.o.laststatus = 0
            -- vim.o.lines = 10 > vim.o.lines and 10 or vim.o.lines
            -- vim.o.columns = 60 > vim.o.columns and 60 or vim.o.columns
        end
    end
})
vim.api.nvim_create_autocmd({'BufEnter'}, {
    pattern = "github.com_*.txt",
    command = "set filetype=markdown"
})
vim.api.nvim_create_autocmd({'BufEnter'}, {
    pattern = "app.slack.com_*.txt",
    command = "set filetype=markdown | set lines=4 | set columns=90"
})
vim.api.nvim_create_autocmd({'BufEnter'}, {
    pattern = "*scripthelp*.txt",
    command = "set filetype=python"
})
