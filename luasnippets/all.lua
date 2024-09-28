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

-- Every unspecified option will be set to the default.
ls.config.set_config({
  history = true,
  -- Update more often, :h events for more info.
  update_events = "TextChanged,TextChangedI",
  -- Snippets aren't automatically removed if their text is deleted.
  -- `delete_check_events` determines on which events (:h events) a check for
  -- deleted snippets is performed.
  -- This can be especially useful when `history` is enabled.
  delete_check_events = "TextChanged",
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { "choiceNode", "Comment" } },
      },
    },
  },
  -- treesitter-hl has 100, use something higher (default is 200).
  ext_base_prio = 300,
  -- minimal increase in priority.
  ext_prio_increase = 1,
  enable_autosnippets = true,
  -- mapping for cutting selected text so it's usable as SELECT_DEDENT,
  -- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
  store_selection_keys = "<Tab>",
  -- luasnip uses this function to get the currently active filetype. This
  -- is the (rather uninteresting) default, but it's possible to use
  -- eg. treesitter for getting the current filetype by setting ft_func to
  -- require("luasnip.extras.filetype_functions").from_cursor (requires
  -- `nvim-treesitter/nvim-treesitter`). This allows correctly resolving
  -- the current filetype in eg. a markdown-code block or `vim.cmd()`.
  ft_func = function()
    return vim.split(vim.bo.filetype, ".", true)
  end,
})

-- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- placeholder 2,...
local function copy(args)
  return args[1]
end

local function testfunc(args, snip)
  -- file = io.open("/tmp/sage/in.py", "w")
  -- io.output(file)
  -- io.write("from sage.all_cmdline import *\n")
  -- io.write("with open('/tmp/sage/out.tex', 'w') as f:\n\t")
  -- io.write(table.concat(args[1], "\n\t"))
  -- io.close()
  -- os.execute("sage /tmp/sage/in.py")
  -- file = io.open("/tmp/sage/out.tex", "r")
  -- io.input(file)
  -- io.close(file)
  -- return io.read(file)
  -- return table.concat(args[1], "")
  return "Trigger: " .. snip.trigger
end

return {
  -- s("fn", {
  --   -- Simple static text.
  --   t("//Parameters: "),
  --   -- function, first parameter is the function, second the Placeholders
  --   -- whose text it gets as input.
  --   f(copy, 2),
  --   t({ "", "function " }),
  --   -- Placeholder/Insert.
  --   i(1),
  --   t("("),
  --   -- Placeholder with initial text.
  --   i(2, "int foo"),
  --   -- Linebreak
  --   t({ ") {", "\t" }),
  --   -- Last Placeholder, exit Point of the snippet.
  --   i(0),
  --   t({ "", "}" }),
  -- }),
  -- s("fn basic", {
  --   t("-- @param: "), f(copy, 2),
  --   t({ "", "local " }), i(1), t(" = function("), i(2, "fn param"), t({ ")", "\t" }),
  --   i(0), -- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
  --   t({ "", "end" }),
  -- }),
  -- s({ trig = "st.*se", regTrig = true }, {
  --   f(testfunc, {}),
  -- }),
}
