vim.opt.guifont = "FiraCode Nerd Font:h14"
vim.g.firenvim_config = {
  globalSettings = {},
  localSettings = {
    [".*"] = {
      takeover = "never",
      cmdline = "neovim",
    },
  },
}
vim.keymap.set("i", "<C-v>", "<C-r>*")
vim.keymap.set("i", "<C-v>", "<C-r>*")
vim.keymap.set("c", "<C-S-v>", "<C-r>*")
vim.keymap.set("c", "<C-S-v>", "<C-r>*")
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
    pattern = "*scripthelp*.txt",
    command = "set filetype=python"
})
