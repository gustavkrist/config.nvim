local M = {}
M.in_codeblock = function()
  local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local linenum, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local before = 0
  local after = 0
  for j, line in ipairs(content) do
    if string.find(line, "^```") then
      if j ~= linenum then
        if j < linenum then
          before = before + 1
        else
          after = after + 1
        end
      end
    end
  end
  if before % 2 == 1 and after % 2 == 1 then
    linenum = vim.fn.search("^```", "bnW")
    local line = unpack(vim.api.nvim_buf_get_lines(0, linenum - 1, linenum, false))
    local language = string.sub(line, 4, -1)
    return { true, language }
  else
    return { false, "" }
  end
end

M.in_language_block = function(langs)
  local in_block, language = unpack(M.in_codeblock())
  local tbl = {}
  if in_block then
    for _, lang in pairs(langs) do
      tbl[lang] = true
    end
    if tbl[language] ~= nil then
      return true
    end
  end
  return false
end

return M
