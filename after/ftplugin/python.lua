local map = vim.keymap.set
map("n", "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "Select VirtualEnv", silent = true, noremap = true, buffer = 0 })
map(
  "n",
  "<leader>vd",
  "<cmd>lua require('venv-selector').deactivate()<cr>",
  { desc = "Deactivate VirtualEnv", silent = true, noremap = true, buffer = 0 }
)

local status_ok, whichkey = pcall(require, "which-key")
if not status_ok then
  return
end
whichkey.add({ "<leader>v", group = "VirtualEnvs", buffer = 0 })
