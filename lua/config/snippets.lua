-- Snippets
require("luasnip").filetype_extend("rmd", { "tex" })
require("luasnip").filetype_extend("md", { "tex" })
require("luasnip").filetype_extend("markdown", { "tex" })
require("luasnip").filetype_extend("pandoc", { "tex" })
require("luasnip").filetype_extend("pandoc", { "markdown" })
require("luasnip.loaders.from_lua").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load()
