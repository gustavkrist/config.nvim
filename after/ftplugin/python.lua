local pythonpath
if require("util.os").is_macos() then
  local conda = os.getenv("CONDA_PREFIX") or (os.getenv("HOME") .. "/mambaforge")
  pythonpath = conda .. "/bin/python"
else
  pythonpath = "python"
end
vim.keymap.set(
  "n",
  "<F9>",
  [[<cmd>2TermExec size=70 direction=vertical cmd="]] .. pythonpath .. [[ %"<cr>]],
  { noremap = true, silent = true, buffer = 0 }
)
