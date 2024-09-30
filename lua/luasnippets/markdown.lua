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

local tsutil = ls_tracked_dopackage("util.treesitter")

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
  s(
    {
      trig = "ch",
      name = "[C]urrent [h]eader level",
    },
    {
      f(function() return string.rep("#", tsutil.get_header_level()) .. " " end), i(1)
    }
  ),
  s(
    {
      trig = "nh",
      name = "[N]ext [h]eader level",
    },
    {
      f(function() return string.rep("#", tsutil.get_header_level() + 1) .. " " end), i(1)
    }
  ),
  s(
    {
      trig = "ph",
      name = "[P]revious [h]eader level",
    },
    {
      f(function() return string.rep("#", tsutil.get_header_level() - 1) .. " " end), i(1)
    }
  ),
  s(
    {
      trig = "li",
      desc = "Markdown [li]nk"
    },
    fmt("[{}]({})", { i(1, "text"), i(2, "url") })
  ),
  s(
    {
      trig = "st",
      desc = "[S]trike[t]hrough text"
    },
    fmt("~~{}~~", i(1))
  ),
  s(
    {
      trig = "i",
      desc = "[I]talic text"
    },
    fmt("*{}*", i(1))
  ),
  s(
    {
      trig = "b",
      desc = "[B]old text"
    },
    fmt("**{}**", i(1))
  ),
  s(
    {
      trig = "bi",
      desc = "[B]old and [i]talic text"
    },
    fmt("***{}***", i(1))
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
  s(
    {
      trig = ">",
      condition = conds.has_selected_text,
    },
    f(function(_, snip)
      local res, env = {}, snip.env
      for _, ele in ipairs(env.TM_SELECTED_TEXT) do
        table.insert(res, "> " .. ele)
      end
      return res
    end)
  ),
  s(
    {
      trig = "co",
      condition = conds.has_selected_text,
      desc = "Wrap selection in callout"
    },
    d(1, function(_, snip)
      local res, env = {}, snip.env
      vim.list_extend(res, fmt("> [!{}]", { c(1, {
        i(0, "NOTE"),
        t("EXAMPLE"),
        t("INFO"),
        t("TODO"),
        t("TIP"),
        t("IMPORTANT"),
        t("WARNING"),
        t("CAUTION"),
      }) }))
      for _, ele in ipairs(env.TM_SELECTED_TEXT) do
        table.insert(res, t({ "", "> " .. ele }))
      end
      return sn(nil, res)
    end)
  )
}

return snippets, autosnippets
