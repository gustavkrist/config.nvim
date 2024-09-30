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
  s({
    trig = "lc",
    desc = "[L]ist [c]omprehension",
  }, fmt("[{} for {} in {}]", { i(1, "value"), i(2, "iterable"), i(3, "iterable") })),
  s({
    trig = "dc",
    desc = "[D]ictionary [c]omprehension",
  }, fmta("{<>: <> for <>, <> in <>}", { i(1, "key"), i(2, "value"), i(3, "key"), i(4, "value"), i(5, "iterable") })),
  s({
    trig = "sc",
    desc = "[S]et [c]omprehension",
  }, fmta("{<> for <> in <>}", { i(1, "value"), i(2, "iterable"), i(3, "iterable") })),
  s({
    trig = "gc",
    desc = "[G]enerator [c]omprehension",
  }, fmt("({} for {} in {})", { i(1, "value"), i(2, "iterable"), i(3, "iterable") })),
  s(
    {
      trig = "forrl",
      desc = "[For] _ in [r]ange([l]en(object))",
    },
    fmt(
      [[
      for {} in range(len({})):
          {}
    ]],
      { i(1, "i"), i(2, "object"), i(3, "pass") }
    )
  ),
  s(
    { trig = "rdb", desc = "Celery [r]emote [d]e[b]ugger trace" },
    t('__import__("celery.contrib.rdb", list=True).set_trace()')
  ),
  s(
    {
      trig = "#env",
      desc = "Shebang line for python script",
    },
    t("#!/usr/bin/env python")
  ),
  s(
    {
      trig = "s",
      hidden = true
    },
    t("self.")
  ),
  s(
    {
      trig = "fim",
      hidden = true,
    },
    fmt("from {} import {}", { i(1, "sys"), i(2, "stdin") })
  ),
  s(
    {
      trig = "deft",
      desc = "Function [def]inition with return [t]ype"
    },
    fmt([[
    def {}({}) -> {}:
        {}
    ]], { i(1, "fname"), i(2), i(3, "None"), i(4, "pass") })
  ),
}

local autosnippets = {
  s({
    trig = "ifmain",
    condition = conds.line_begin,
  }, t({ 'if __name__ == "__main__":', "    main()" })),
}

return snippets, autosnippets
