local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
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

return {}, {
  s("select", t("SELECT")),
  s("from", t("FROM")),
  s("join", t("JOIN")),
  s({trig = "inner join", priority = 1001}, t("INNER JOIN")),
  s({trig = "outer join", priority = 1001}, t("OUTER JOIN")),
  s({trig = "left outer join", priority = 1002}, t("LEFT OUTER JOIN")),
  s({trig = "right outer join", priority = 1002}, t("RIGHT OUTER JOIN")),
  s("as ", t("AS ")),
  s("on ", t("ON ")),
  s("where", t("WHERE")),
  s("declare", t("DECLARE")),
  s("create table", t("CREATE TABLE")),
  s("integer", t("INTEGER")),
  s("int", t("INT")),
  s("varchar", t("VARCHAR")),
  s("char", t("CHAR")),
  s("float", t("FLOAT")),
  s("double", t("DOUBLE")),
  s("null", t("NULL")),
  s("primary key", t("PRIMARY KEY")),
  s("foreign key", t("FOREIGN KEY")),
  s("references", t("REFERENCES")),
  s("raise exception", t("RAISE EXCEPTION")),
  s("function", t("FUNCTION")),
  s("if", t("IF")),
  s("end", t("END")),
  s("else", t("ELSE")),
  s("then", t("THEN")),
  s("create index", t("CREATE INDEX")),
  s("using errcode", t("USING ERRCODE")),
  s("sum(", t("SUM(")),
  s("count(", t("COUNT(")),
  s("group by", t("GROUP BY")),
  s("having", t("HAVING")),
  s("union", t("UNION")),
  s("UNION all", t("UNION ALL")),
  s(
    {
      trig = "FROM (%l)(%l+) (%l) (.-)JOIN ",
      regTrig = true,
    },
    f(function(_, snip)
      return "FROM "
        .. string.upper(snip.captures[1])
        .. snip.captures[2]
        .. " "
        .. string.upper(snip.captures[3])
        .. " "
        .. snip.captures[4]
        .. "JOIN "
    end)
  ),
  s(
    {
      trig = "from (%l)(%l+) (%l) (.-)join ",
      regTrig = true,
    },
    f(function(_, snip)
      return "FROM "
        .. string.upper(snip.captures[1])
        .. snip.captures[2]
        .. " "
        .. string.upper(snip.captures[3])
        .. " "
        .. snip.captures[4]
        .. "JOIN "
    end)
  ),
  s(
    {
      trig = "JOIN (%l)(%l+) (%l)",
      regTrig = true,
    },
    f(function(_, snip)
      return "JOIN " .. string.upper(snip.captures[1]) .. snip.captures[2] .. " " .. string.upper(snip.captures[3])
    end)
  ),
  s(
    {
      trig = "join (%l)(%l+) (%l)",
      regTrig = true,
    },
    f(function(_, snip)
      return "JOIN " .. string.upper(snip.captures[1]) .. snip.captures[2] .. " " .. string.upper(snip.captures[3])
    end)
  ),
  s(
    {
      trig = "(%l)?(%l)%.(%l)(%l+) ",
      regTrig = true,
    },
    f(function(_, snip)
      return string.upper(snip.captures[1]) .. "." .. string.upper(snip.captures[2]) .. snip.captures[3] .. " "
    end)
  ),
}
