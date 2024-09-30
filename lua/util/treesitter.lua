-- This Lua module provides utility functions using nvim-treesitter to check the
-- node position in the AST.

local has_treesitter, ts = pcall(require, "vim.treesitter")

---@class util.treesitter
local M = {}

local MATH_ENVIRONMENTS = {
  displaymath = true,
  equation = true,
  eqnarray = true,
  align = true,
  math = true,
  array = true,
}

local MATH_NODES = {
  displayed_equation = true,
  inline_formula = true,
}

local function get_node_at_cursor(lang)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_range = { cursor[1] - 1, cursor[2] }
  local buf = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(ts.get_parser, buf, lang)
  if not ok or not parser then
    return
  end
  local root_tree = parser:parse()[1]
  local root = root_tree and root_tree:root()

  if not root then
    return
  end

  return root:named_descendant_for_range(cursor_range[1], cursor_range[2], cursor_range[1], cursor_range[2])
end

-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1184#issuecomment-830388856
function M.in_mathzone()
  if not has_treesitter then
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local node = get_node_at_cursor("latex")
  while node do
    if MATH_NODES[node:type()] then
      return true
    elseif node:type() == "math_environment" or node:type() == "generic_environment" then
      local begin = node:child(0)
      local names = begin and begin:field("name")
      if names and names[1] and MATH_ENVIRONMENTS[ts.get_node_text(names[1], buf):match("[A-Za-z]+")] then
        return true
      end
    end
    node = node:parent()
  end
  return false
end

function M.in_comment()
  if not has_treesitter then
    return
  end
  local node = ts.get_node({ ignore_injections = false })
  while node and (node:type() ~= "comment") do
    node = node:parent()
  end
  return node ~= nil
end

---@param lang? string|string[]
function M.in_codeblock(lang)
  if not has_treesitter then
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local node = ts.get_node()
  while node and (node:type() ~= "fenced_code_block") do
    node = node:parent()
  end
  if not node then
    return false
  end
  local info_node = nil
  for child in node:iter_children() do
    if child:type() == "info_string" then
      info_node = child
    end
  end
  if not info_node then
    return false
  end
  local lang_node = nil
  for child in info_node:iter_children() do
    if child:type() == "language" then
      lang_node = child
    end
  end
  if not lang_node then
    return false
  end
  local code_block_lang = ts.get_node_text(lang_node, buf)
  if type(lang) == "string" then
    return code_block_lang:lower() == lang:lower()
  end
  if type(lang) == "table" then
    return vim.tbl_contains(lang, code_block_lang:lower())
  end
  return true
end

function M.get_header_level()
  if not has_treesitter then
    return 1
  end
  local node = ts.get_node()
  while node and (node:type() ~= "section") do
    node = node:parent()
  end
  if not node then
    return 1
  end
  local header_level = nil
  for child in node:iter_children() do
    if child:type() == "atx_heading" then
      for gchild in child:iter_children() do
        header_level = gchild:type():match("atx_h(%d)_marker")
        break
      end
      break
    end
  end
  if not header_level then
    print("Could not find atx_h_marker for heading")
    return 1
  end
  return tonumber(header_level) or 1
end

return M
