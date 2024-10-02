vim.keymap.set(
  "n",
  "dd",
  "<cmd>call setqflist(filter(getqflist(), {idx -> idx != line('.') - 1}), 'r') <Bar> cc<cr>",
  { noremap = true, silent = true, buffer = 0 }
)
