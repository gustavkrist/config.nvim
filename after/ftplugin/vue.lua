local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
  return
end
local sources = {}
if vim.fn.executable("eslint") == 1 then
  table.insert(sources, require("none-ls.diagnostics.eslint"))
end
null_ls.register({
  sources = sources,
})
