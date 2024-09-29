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

local M = {}

M.snippets = {}

local in_codeblock = require("util.treesitter").in_codeblock

local function in_sql_block()
  return in_codeblock({ "sql", "SQL", "PostgreSQL" })
end
M.autosnippets = {
  { "select",                                       t("SELECT") },
  { "from",                                         t("FROM") },
  { "join",                                         t("JOIN") },
  { { trig = "inner join", priority = 1001 },       t("INNER JOIN") },
  { { trig = "outer join", priority = 1001 },       t("OUTER JOIN") },
  { { trig = "left outer join", priority = 1002 },  t("LEFT OUTER JOIN") },
  { { trig = "right outer join", priority = 1002 }, t("RIGHT OUTER JOIN") },
  { "as ",                                          t("AS ") },
  { "on ",                                          t("ON ") },
  { "where",                                        t("WHERE") },
  { "declare",                                      t("DECLARE") },
  { "create table",                                 t("CREATE TABLE") },
  { "integer",                                      t("INTEGER") },
  { "int",                                          t("INT") },
  { "varchar",                                      t("VARCHAR") },
  { "char",                                         t("CHAR") },
  { "float",                                        t("FLOAT") },
  { "double",                                       t("DOUBLE") },
  { "null",                                         t("NULL") },
  { "primary key",                                  t("PRIMARY KEY") },
  { "foreign key",                                  t("FOREIGN KEY") },
  { "references",                                   t("REFERENCES") },
  { "raise exception",                              t("RAISE EXCEPTION") },
  { "function",                                     t("FUNCTION") },
  { "if",                                           t("IF") },
  { "end",                                          t("END") },
  { "else",                                         t("ELSE") },
  { "then",                                         t("THEN") },
  { "create index",                                 t("CREATE INDEX") },
  { "using errcode",                                t("USING ERRCODE") },
  { "sum(",                                         t("SUM(") },
  { "count(",                                       t("COUNT(") },
  { "group by",                                     t("GROUP BY") },
  { "having",                                       t("HAVING") },
  { "union",                                        t("UNION") },
  { "UNION all",                                    t("UNION ALL") },
  {
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
  },
  {
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
  },
  {
    {
      trig = "JOIN (%l)(%l+) (%l)",
      regTrig = true,
    },
    f(function(_, snip)
      return "JOIN " .. string.upper(snip.captures[1]) .. snip.captures[2] .. " " .. string.upper(snip.captures[3])
    end)
  },
  {
    {
      trig = "join (%l)(%l+) (%l)",
      regTrig = true,
    },
    f(function(_, snip)
      return "JOIN " .. string.upper(snip.captures[1]) .. snip.captures[2] .. " " .. string.upper(snip.captures[3])
    end)
  },
  {
    {
      trig = "(%l)?(%l)%.(%l)(%l+) ",
      regTrig = true,
    },
    f(function(_, snip)
      return string.upper(snip.captures[1]) .. "." .. string.upper(snip.captures[2]) .. snip.captures[3] .. " "
    end)
  },
}

return M
