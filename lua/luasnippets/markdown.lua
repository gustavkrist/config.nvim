local s = require("luasnip").snippet

local in_codeblock = require("util.treesitter").in_codeblock

local function in_sql_block()
  return in_codeblock({ "sql", "SQL", "PostgreSQL" })
end

local sql_definitions = require("luasnippets.definitions.sql")
local tex_definitions = require("luasnippets.definitions.tex")

local snippets = {}
local autosnippets = {}

for _, def in ipairs(sql_definitions.snippets) do
  local context, nodes, opts = unpack(def)
  opts = opts or {}
  opts.condition = in_sql_block
  table.insert(snippets, s(context, nodes, opts))
end
for _, def in ipairs(sql_definitions.autosnippets) do
  local context, nodes, opts = unpack(def)
  opts = opts or {}
  opts.condition = in_sql_block
  table.insert(autosnippets, s(context, nodes, opts))
end

for _, def in ipairs(tex_definitions.snippets) do
  table.insert(snippets, s(unpack(def)))
end
for _, def in ipairs(tex_definitions.autosnippets) do
  table.insert(autosnippets, s(unpack(def)))
end


return snippets, autosnippets
