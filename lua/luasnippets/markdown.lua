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
      trig = "aligns",
      name = "Align*",
      wordTrig = true,
    },
    {
      t({ "\\begin{align*}", "" }),
      t("\t"),
      d(1, function(_, snip)
        local res, env = {}, snip.env
        if env.LS_SELECT_RAW[1] ~= nil then
          for _, ele in ipairs(env.LS_SELECT_RAW) do
            table.insert(res, ele)
          end
          return sn(nil, t(res))
        end
        return sn(nil, i(1))
      end),
      t({ "", "\\end{align*}" }),
    }
  ),
}

local autosnippets = {
  s(
    {
      trig = "mk",
      name = "Inline Math",
    },
    {
      t("$"),
      i(1),
      t("$"),
    }
  ),
  s(
    {
      trig = "dm",
      name = "Display Math",
    },
    {
      t({ "$$", "" }),
      i(0),
      t({ "", "$$" }),
    }
  ),
}

return snippets, autosnippets
