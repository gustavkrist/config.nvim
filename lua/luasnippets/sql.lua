local s = require("luasnip").snippet

local definitions = require("luasnippets.definitions.sql")

local snippets = {}
local autosnippets = {}

for _, def in ipairs(definitions.snippets) do
  table.insert(snippets, s(unpack(def)))
end
for _, def in ipairs(definitions.autosnippets) do
  table.insert(autosnippets, s(unpack(def)))
end

return snippets, autosnippets
