local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local ms = ls.multi_snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

local snippets = {
  s(
    {
      trig = "autocmd",
      desc = "Create neovim autocmd",
    },
    fmta([[
      vim.api.nvim_create_autocmd("<event>", {
        group = vim.api.nvim_create_augroup("<group>", { clear = true }),
        callback = function(ev)
          <body>
        end
      })
      ]], {
      event = i(1, "event"),
      group = i(2, "group"),
      body = i(3, "return"),
    })
  ),
  s(
    {
      trig = "augroup",
      desc = "Create neovim augroup",
    },
    fmta([[vim.api.nvim_create_augroup("<group>", { clear = true })]], { group = i(1, "group") })
  ),
  s(
    {
      trig = "win",
      desc = "Current window"
    },
    t("local win = vim.api.nvim_get_current_win()")
  ),
  s(
    {
      trig = "buf",
      desc = "Current buffer"
    },
    t("local buf = vim.api.nvim_get_current_buf()")
  ),
}

local autosnippets = {}

return snippets, autosnippets
