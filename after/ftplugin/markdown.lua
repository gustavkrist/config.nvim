local status_ok, otter = pcall(require, "otter")
if status_ok then
  vim.keymap.set("n", "<leader>oa", function()
    otter.activate()
  end, { desc = "Activate otter", buffer = 0 })
  vim.keymap.set("n", "<leader>od", function()
    otter.deactivate()
  end, { desc = "Deactivate otter", buffer = 0 })
end
