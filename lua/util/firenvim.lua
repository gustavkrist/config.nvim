local M = setmetatable({}, {
  __call = function(m)
    return m.get()
  end,
})

function M.get()
  return (vim.g.started_by_firenvim ~= nil) or (vim.g.started_by_surfingkeys ~= nil)
end

return M
