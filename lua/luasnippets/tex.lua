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
local events = require("luasnip.util.events")

local in_mathzone = require("util.treesitter").in_mathzone

local function not_in_mathzone()
  return not in_mathzone()
end

local function enable_matrix_bindings()
  vim.keymap.set("i", "<Tab>", " & ", { noremap = true, silent = true, buffer = 0 })
  vim.keymap.set("i", "<CR>", " \\\\<CR>", { noremap = true, silent = true, buffer = 0 })
  vim.keymap.set("i", "<ESC>", require("luasnip").expand_or_jump, { noremap = true, silent = true, buffer = 0 })
end

local function disable_matrix_bindings()
  vim.keymap.del("i", "<Tab>", { buffer = 0 })
  vim.keymap.del("i", "<CR>", { buffer = 0 })
  vim.keymap.del("i", "<ESC>", { buffer = 0 })
end

local function expand_surrounding_delims()
  local delims = vim.fn["vimtex#delim#get_surrounding"]("delim_modq_math")
  local left = delims[1]
  local right = delims[2]
  local cursor = vim.api.nvim_win_get_cursor(0)
  if left["delim"] ~= nil and right["delim"] ~= nil then
    if left["mod"] ~= "\\left" then
      vim.fn["vimtex#delim#toggle_modifier"]()
      if left["lnum"] == cursor[1] then
        cursor[2] = cursor[2] + 5
      end
    end
  end
  vim.api.nvim_win_set_cursor(0, cursor)
end

local greek = {
  alpha = "alpha",
  beta = "beta",
  gamma = "gamma",
  Gamma = "Gamma",
  delta = "delta",
  Delta = "Delta",
  epsilon = "epsilon",
  varepsilon = "varepsilon",
  zeta = "zeta",
  eta = "eta",
  theta = "theta",
  Theta = "Theta",
  iota = "iota",
  kappa = "kappa",
  lambda = "lambda",
  Lambda = "Lambda",
  mu = "mu",
  nu = "nu",
  xi = "xi",
  Xi = "Xi",
  pi = "pi",
  Pi = "Pi",
  rho = "rho",
  sigma = "sigma",
  Sigma = "Sigma",
  tau = "tau",
  upsilon = "upsilon",
  varphi = "varphi",
  phi = "phi",
  Phi = "Phi",
  chi = "chi",
  psi = "psi",
  Psi = "Psi",
  omega = "omega",
  Omega = "Omega",
}

local symbols = {
  hbar = "hbar",
  ell = "ell",
  nabla = "nabla",
  infty = "infty",
  dots = "dots",
  to = "to",
  leftrightarrow = "leftrightarrow",
  mapsto = "mapsto",
  setminus = "setminus",
  mid = "mid",
  cap = "cap",
  cup = "cup",
  land = "land",
  lor = "lor",
  subseteq = "subseteq",
  subset = "subset",
  implies = "implies",
  impliedby = "impliedby",
  iff = "iff",
  exists = "exists",
  equiv = "equiv",
  square = "square",
  neq = "neq",
  geq = "geq",
  leq = "leq",
  gg = "gg",
  ll = "ll",
  sim = "sim",
  simeq = "simeq",
  approx = "approx",
  propto = "propto",
  cdot = "cdot",
  oplus = "oplus",
  otimes = "otimes",
  times = "times",
  star = "star",
  perp = "perp",
  det = "det",
  exp = "exp",
  ln = "ln",
  log = "log",
  partial = "partial",
}

local at_signs = {
  ["@a"] = "\\alpha",
  ["@A"] = "\\alpha",
  ["@b"] = "\\beta",
  ["@B"] = "\\beta",
  ["@c"] = "\\chi",
  ["@C"] = "\\chi",
  ["@g"] = "\\gamma",
  ["@G"] = "\\Gamma",
  ["@d"] = "\\delta",
  ["@D"] = "\\Delta",
  ["@e"] = "\\epsilon",
  ["@E"] = "\\epsilon",
  [":e"] = "\\varepsilon",
  [":E"] = "\\varepsilon",
  ["@z"] = "\\zeta",
  ["@Z"] = "\\zeta",
  ["@t"] = "\\theta",
  ["@T"] = "\\Theta",
  ["@k"] = "\\kappa",
  ["@K"] = "\\kappa",
  ["@l"] = "\\lambda",
  ["@L"] = "\\Lambda",
  ["@m"] = "\\mu",
  ["@M"] = "\\mu",
  ["@r"] = "\\rho",
  ["@R"] = "\\rho",
  ["@s"] = "\\sigma",
  ["@S"] = "\\Sigma",
  ["ome"] = "\\omega",
  ["@o"] = "\\omega",
  ["@O"] = "\\Omega",
  ["@x"] = "\\xi",
  ["@."] = "\\cdot",
}

local degree_functions = {
  sin = "sin",
  cos = "cos",
  tan = "tan",
  cot = "cot",
  csc = "csc",
}

local arc_functions = {
  arcsin = "arcsin",
  arccos = "arccos",
  arctan = "arctan",
  arccot = "arccot",
  arccsc = "arccsc",
  arcsec = "arcsec",
}

local function is_greek_or_symbol_1(_, _, captures)
  return (greek[captures[1]] ~= nil or symbols[captures[1]] ~= nil) and in_mathzone()
end

local function is_greek_or_symbol_2(_, _, captures)
  return (greek[captures[2]] ~= nil or symbols[captures[2]] ~= nil) and in_mathzone()
end

local autosnippets = {
  -- Math fields
  s({
    trig = "mk",
    name = "Inline Math",
  }, {
    t("$"),
    i(1),
    t("$"),
  }, {
    condition = not_in_mathzone,
  }),
  s({
    trig = "dm",
    name = "Display Math",
  }, {
    t({ "$$", "" }),
    i(0),
    t({ "", "$$" }),
  }, {
    condition = not_in_mathzone,
  }),

  -- Greek letters and symbols

  s(
    {
      trig = "([^\\])(%a+)",
      name = "Greek letters/symbols",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return snip.captures[1] .. "\\" .. snip.captures[2]
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s(
    {
      trig = "^(%a+)",
      name = "Greek letters/symbols start of line",
      regTrig = true,
    },
    f(function(_, snip)
      return "\\" .. snip.captures[1]
    end, {}),
    {
      condition = is_greek_or_symbol_1,
    }
  ),

  -- Space after greek letters and symbols, etc.

  s(
    {
      trig = "(\\)(%a+)(%a)",
      name = "Greek letters/symbols space",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return snip.captures[1] .. snip.captures[2] .. " " .. snip.captures[3]
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s(
    {
      trig = "(\\)(%a+) sr",
      name = "Greek letters/symbols squared",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return snip.captures[1] .. snip.captures[2] .. "^{2}"
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s(
    {
      trig = "(\\)(%a+) cb",
      name = "Greek letters/symbols cubed",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return snip.captures[1] .. snip.captures[2] .. "^{3}"
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s({
    trig = "(\\)(%a+) rd",
    name = "Greek letters/symbols exponent",
    regTrig = true,
    wordTrig = false,
  }, {
    f(function(_, snip)
      return snip.captures[1] .. snip.captures[2] .. "^{"
    end, {}),
    i(1),
    t("}"),
  }, {
    condition = is_greek_or_symbol_2,
  }),
  s(
    {
      trig = "(\\)(%a+) hat",
      name = "Greek letters/symbols hat",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\hat{" .. snip.captures[1] .. snip.captures[2] .. "}"
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s(
    {
      trig = "(\\)(%a+) til",
      name = "Greek letters/symbols til",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\tilde{" .. snip.captures[1] .. snip.captures[2] .. "}"
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s(
    {
      trig = "(\\)(%a+) dot",
      name = "Greek letters/symbols dot",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\dot{" .. snip.captures[1] .. snip.captures[2] .. "}"
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s(
    {
      trig = "(\\)(%a+) ddot",
      name = "Greek letters/symbols ddot",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\ddot{" .. snip.captures[1] .. snip.captures[2] .. "}"
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s(
    {
      trig = "(\\)(%a+) bar",
      name = "Greek letters/symbols bar",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\bar{" .. snip.captures[1] .. snip.captures[2] .. "}"
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s(
    {
      trig = "(\\)(%a+),%.",
      name = "Greek letters/symbols matr",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\matr{" .. snip.captures[1] .. snip.captures[2] .. "}"
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),
  s(
    {
      trig = "(\\)(%a+)%.,",
      name = "Greek letters/symbols mathbf",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. snip.captures[2] .. "}"
    end, {}),
    {
      condition = is_greek_or_symbol_2,
    }
  ),

  -- Operations

  s({
    trig = "bf",
    name = "Math bold font",
    wordTrig = false,
  }, {
    t("\\mathbf{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s(
    {
      trig = "(%a),%.",
      name = "Matrix symbol",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\matr{" .. snip.captures[1] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "(%a)%.,",
      name = "Math bold font",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s({
    trig = "rm",
    name = "Math rm",
    wordTrig = false,
  }, {
    t("\\mathrm{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "opn",
    name = "Operatorname",
    wordTrig = false,
  }, {
    t("\\operatorname{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s(
    {
      trig = "sr",
      name = "Squared",
      wordTrig = false,
    },
    t("^{2}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "cb",
      name = "Cubed",
      wordTrig = false,
    },
    t("^{3}"),
    {
      condition = in_mathzone,
    }
  ),
  s({
    trig = "rd",
    name = "D-exponent",
    wordTrig = false,
  }, {
    t("^{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "_",
    name = "Subscript",
    wordTrig = false,
  }, {
    t("_{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "^",
    name = "Superscript",
    wordTrig = false,
  }, {
    t("^{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "sts",
    name = "Subtext",
    wordTrig = false,
  }, {
    t("_\\text{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "ee",
    name = "E to power of",
    wordTrig = false,
  }, {
    t("e^{ "),
    i(1),
    t(" }"),
  }, {
    condition = in_mathzone,
  }),
  s(
    {
      trig = "(%a)(%d)",
      name = "Auto digit subscript",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\matr{([\\%a]-)}(%d)",
      name = "Auto digit subscript (matr)",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\matr{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\mathbf{([\\%a]-)}(%d)",
      name = "Auto digit subscript (mathbf)",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\mathbf{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\mathrm{([\\%a]-)}(%d)",
      name = "Auto digit subscript (mathrm)",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\mathrm{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\dot{([\\%a]-)}(%d)",
      name = "Auto digit subscript (dot)",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\dot{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\ddot{([\\%a]-)}(%d)",
      name = "Auto digit subscript (ddot)",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\ddot{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\hat{([\\%a]-)}(%d)",
      name = "Auto digit subscript (hat)",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\hat{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\til{([\\%a]-)}(%d)",
      name = "Auto digit subscript (til)",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\tilde{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "([xy])([ijnm])",
      name = "Auto subscript x/y i/j/n/m",
      regTrig = true,
      wordTrig = false,
      priority = 1001,
    },
    f(function(_, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "(%a)bar",
      name = "Bar letter",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\bar{" .. snip.captures[1] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "(%a)hat",
      name = "Hat letter",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\hat{" .. snip.captures[1] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "(%a)til",
      name = "Tilde letter",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\tilde{" .. snip.captures[1] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "(%a)dot",
      name = "Dot letter",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\dot{" .. snip.captures[1] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "(%a)ddot",
      name = "Ddot letter",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\ddot{" .. snip.captures[1] .. "}"
    end),
    {
      condition = in_mathzone,
    }
  ),
  s({
    trig = "dot",
    name = "Dot",
    wordTrig = false,
  }, {
    t("\\dot{"),
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
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "bar",
    name = "Bar",
    wordTrig = false,
  }, {
    t("\\bar{"),
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
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "ddot",
    name = "Ddot",
    wordTrig = false,
  }, {
    t("\\ddot{"),
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
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "matr",
    name = "Matrix letter",
    wordTrig = false,
  }, {
    t("\\matr{"),
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
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "til",
    name = "Tilde",
    wordTrig = false,
  }, {
    t("\\tilde{"),
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
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s(
    {
      trig = "conj",
      name = "Conj",
      wordTrig = false,
    },
    t("^{*}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "trace",
      name = "Trace",
      wordTrig = false,
    },
    t("\\mathrm{Tr}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "det",
      name = "Det",
      wordTrig = false,
    },
    t("\\det"),
    {
      condition = in_mathzone,
    }
  ),

  -- Symbols

  s(
    {
      trig = "ooo",
      name = "Infinity",
      wordTrig = false,
    },
    t("\\infty"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "sum",
      name = "Sum",
      wordTrig = false,
    },
    t("\\sum"),
    {
      condition = in_mathzone,
      callbacks = {
        [-1] = {
          [events.leave] = function()
            vim.defer_fn(expand_surrounding_delims, 100)
          end,
        },
      },
    }
  ),
  s(
    {
      trig = "dsum",
      name = "Sum",
      wordTrig = false,
      priority = 1001,
    },
    t("\\displaystyle\\sum"),
    {
      condition = in_mathzone,
      callbacks = {
        [-1] = {
          [events.leave] = function()
            vim.defer_fn(expand_surrounding_delims, 100)
          end,
        },
      },
    }
  ),
  s({
    trig = "lsum",
    name = "Sum",
    wordTrig = false,
    priority = 1001,
  }, {
    t("\\sum_{"),
    i(1, "i=1"),
    t("}^{"),
    i(2, "n"),
    t("}"),
  }, {
    condition = in_mathzone,
    callbacks = {
      [-1] = {
        [events.leave] = function()
          vim.defer_fn(expand_surrounding_delims, 100)
        end,
      },
    },
  }),
  s({
    trig = "dlsum",
    name = "Sum",
    wordTrig = false,
    priority = 1002,
  }, {
    t("\\displaystyle\\sum_{"),
    i(1, "i=1"),
    t("}^{"),
    i(2, "n"),
    t("}"),
  }, {
    condition = in_mathzone,
    callbacks = {
      [-1] = {
        [events.leave] = function()
          vim.defer_fn(expand_surrounding_delims, 100)
        end,
      },
    },
  }),
  s(
    {
      trig = "prod",
      name = "Prod",
      wordTrig = false,
    },
    t("\\prod"),
    {
      condition = in_mathzone,
    }
  ),
  s({
    trig = "lim",
    name = "Limits",
    wordTrig = false,
  }, {
    t("\\lim_{ "),
    i(1, "n"),
    t(" \\to "),
    i(2, "\\infty"),
    t(" }"),
  }, {
    condition = in_mathzone,
    callbacks = {
      [-1] = {
        [events.leave] = function()
          vim.defer_fn(expand_surrounding_delims, 100)
        end,
      },
    },
  }),
  s(
    {
      trig = "pm",
      name = "\\pm",
      wordTrig = false,
    },
    t("\\pm"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "...",
      name = "\\dots",
      wordTrig = false,
    },
    t("\\dots"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "<->",
      name = "\\leftrightarrow ",
      wordTrig = false,
    },
    t("\\leftrightarrow "),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "->",
      name = "\\to",
      wordTrig = false,
    },
    t("\\to"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "!>",
      name = "\\mapsto",
      wordTrig = false,
    },
    t("\\mapsto"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "invs",
      name = "Inverse",
      wordTrig = false,
    },
    t("^{-1}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\\\\\",
      name = "\\setminus",
      wordTrig = false,
    },
    t("\\setminus"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "||",
      name = "\\mid",
      wordTrig = false,
    },
    t("\\mid"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "and",
      name = "\\cap",
      wordTrig = false,
    },
    t("\\cap"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "orr",
      name = "\\cup",
      wordTrig = false,
    },
    t("\\cup"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "inn",
      name = "\\in",
      wordTrig = false,
    },
    t("\\in"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\subset eq",
      name = "Subset equals",
      wordTrig = false,
    },
    t("\\subseteq"),
    {
      condition = in_mathzone,
    }
  ),
  s({
    trig = "set",
    name = "Set",
    wordTrig = false,
  }, {
    t("\\{ "),
    i(1),
    t(" \\}"),
  }, {
    condition = in_mathzone,
  }),
  s(
    {
      trig = "=>",
      name = "\\implies",
      wordTrig = false,
    },
    t("\\implies"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "=<",
      name = "\\impliedby",
      wordTrig = false,
    },
    t("\\impliedby"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "iff",
      name = "\\iff",
      wordTrig = false,
    },
    t("\\iff"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "ex_{i}sts",
      name = "Exists",
      wordTrig = false,
      priority = 1001,
    },
    t("\\exists"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "===",
      name = "Equivalent to",
      wordTrig = false,
    },
    t("\\equiv"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "Sq",
      name = "Square",
      wordTrig = false,
    },
    t("\\square"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "!=",
      name = "Not equals",
      wordTrig = false,
    },
    t("\\neq"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = ">=",
      name = "Greater than or equal to",
      wordTrig = false,
    },
    t("\\geq"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "<=",
      name = "Less than or equal to",
      wordTrig = false,
    },
    t("\\leq"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = ">>",
      name = "Much greater",
      wordTrig = false,
    },
    t("\\gg"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "<<",
      name = "Much lower",
      wordTrig = false,
    },
    t("\\ll"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "~~",
      name = "Similar to",
      wordTrig = false,
    },
    t("\\sim"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\sim ~",
      name = "Approximately",
      wordTrig = false,
    },
    t("\\approx"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "prop",
      name = "Proportional to",
      wordTrig = false,
    },
    t("\\propto"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "nabl",
      name = "Gradient",
      wordTrig = false,
    },
    t("\\nabla"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "del",
      name = "Gradient",
      wordTrig = false,
    },
    t("\\nabla"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "xx",
      name = "Times",
      wordTrig = false,
    },
    t("\\times"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "**",
      name = "Cdot",
      wordTrig = false,
    },
    t("\\cdot"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "pal",
      name = "Parallel to",
      wordTrig = false,
    },
    t("\\parallel"),
    {
      condition = in_mathzone,
    }
  ),

  s(
    {
      trig = "xp1",
      name = "x_{n+1}",
      wordTrig = false,
    },
    t("x_{n+1}"),
    {
      condition = in_mathzone,
    }
  ),

  s({
    trig = "mcal",
    name = "Mathcal",
    wordTrig = false,
  }, {
    t("\\mathcal{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s(
    {
      trig = "ell",
      name = "Ell",
      wordTrig = false,
    },
    t("\\ell"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "lll",
      name = "Ell",
      wordTrig = false,
    },
    t("\\ell"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "LL",
      name = "\\mathcal{L}",
      wordTrig = false,
    },
    t("\\mathcal{L}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "HH",
      name = "\\mathcal{H}",
      wordTrig = false,
    },
    t("\\mathcal{H}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "CC",
      name = "\\mathbb{C}",
      wordTrig = false,
    },
    t("\\mathbb{C}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "RR",
      name = "\\mathbb{R}",
      wordTrig = false,
    },
    t("\\mathbb{R}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "ZZ",
      name = "\\mathbb{Z}",
      wordTrig = false,
    },
    t("\\mathbb{Z}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "NN",
      name = "\\mathbb{N}",
      wordTrig = false,
    },
    t("\\mathbb{N}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "II",
      name = "\\mathbb{1}",
      wordTrig = false,
    },
    t("\\mathbb{1}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "\\mathbb{1}I",
      name = "\\hat{\\mathbb{1}}",
      wordTrig = false,
    },
    t("\\hat{\\mathbb{1}}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "AA",
      name = "\\mathcal{A}",
      wordTrig = false,
    },
    t("\\mathcal{A}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "BB",
      name = "\\mathbf{B}",
      wordTrig = false,
    },
    t("\\mathbf{B}"),
    {
      condition = in_mathzone,
    }
  ),
  s(
    {
      trig = "EE",
      name = "\\mathbf{E}",
      wordTrig = false,
    },
    t("\\mathbf{E}"),
    {
      condition = in_mathzone,
    }
  ),

  -- Derivatives

  s({
    trig = "par",
    name = "Partial",
    wordTrig = false,
  }, {
    t("\\frac{ \\partial "),
    i(1, "y"),
    t(" }{ \\partial "),
    i(2, "x"),
    t(" }"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "pa2",
    name = "Partial (2nd order)",
    wordTrig = false,
    priority = 1001,
  }, {
    t("\\frac{ \\partial^{2} "),
    i(1, "y"),
    t(" }{ \\partial "),
    i(2, "x"),
    t("^{2} }"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "pa3",
    name = "Partial (3nd order)",
    wordTrig = false,
    priority = 1001,
  }, {
    t("\\frac{ \\partial^{3} "),
    i(1, "y"),
    t(" }{ \\partial "),
    i(2, "x"),
    t("^{3} }"),
  }, {
    condition = in_mathzone,
  }),

  -- Integrals

  s({
    trig = "int",
    name = "Integral",
    wordTrig = false,
  }, {
    t("\\int "),
    i(1),
    t(" \\diff "),
    i(2, "x"),
  }, {
    condition = in_mathzone,
    callbacks = {
      [-1] = {
        [events.leave] = function()
          vim.defer_fn(expand_surrounding_delims, 100)
        end,
      },
    },
  }),
  s({
    trig = "lint",
    name = "Integral",
    wordTrig = false,
    priority = 1001,
  }, {
    t("\\int_{"),
    i(1, "-\\infty"),
    t("}^{"),
    i(2, "\\infty"),
    t("} "),
    i(3),
    t(" \\diff "),
    i(4, "x"),
  }, {
    condition = in_mathzone,
    callbacks = {
      [-1] = {
        [events.leave] = function()
          vim.defer_fn(expand_surrounding_delims, 100)
        end,
      },
    },
  }),

  -- Environments

  s({
    trig = "([bpBvV])mat",
    name = "Matrix",
    regTrig = true,
    wordTrig = false,
  }, {
    f(function(_, snip)
      return { "\\begin{" .. snip.captures[1] .. "matrix}", "" }
    end),
    t("\t"),
    i(1),
    f(function(_, snip)
      return { "", "\\end{" .. snip.captures[1] .. "matrix}" }
    end),
  }, {
    condition = in_mathzone,
    callbacks = {
      [-1] = {
        [events.enter] = enable_matrix_bindings,
        [events.leave] = disable_matrix_bindings,
      },
    },
  }),
  s({
    trig = "case",
    name = "Case",
    wordTrig = false,
  }, {
    t({ "\\begin{cases}", "" }),
    t("\t"),
    i(1),
    t({ "\\end{cases}", "" }),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "align",
    name = "Align",
    wordTrig = false,
  }, {
    t({ "\\begin{align}", "" }),
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
    t({ "", "\\end{align}" }),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "begin",
    name = "Environment",
    wordTrig = false,
  }, {
    t("\\begin{"),
    i(1),
    t({ "}", "" }),
    t("\t"),
    d(2, function(_, snip)
      local res, env = {}, snip.env
      if env.LS_SELECT_RAW[1] ~= nil then
        for _, ele in ipairs(env.LS_SELECT_RAW) do
          table.insert(res, ele)
        end
        return sn(nil, t(res))
      end
      return sn(nil, i(1))
    end),
    t({ "", "\\end{" }),
    f(function(args)
      return args[1][1]
    end, { 1 }),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "array",
    name = "Array",
    wordTrig = false,
  }, {
    t({ "\\begin{array}", "" }),
    t("\t"),
    i(1),
    t({ "\\end{array}", "" }),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "matrix",
    name = "Matrix",
    wordTrig = false,
  }, {
    t({ "\\begin{matrix}", "" }),
    t("\t"),
    i(1),
    t({ "\\end{matrix}", "" }),
  }, {
    condition = in_mathzone,
  }),

  -- Brackets

  s({
    trig = "lr)",
    name = "Left/right paren",
    wordTrig = false,
  }, {
    t("\\left("),
    i(1),
    t("\\right)"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "lr|",
    name = "Left/right bars",
    wordTrig = false,
  }, {
    t("\\left|"),
    i(1),
    t("\\right|"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "lr]",
    name = "Left/right brackets",
    wordTrig = false,
  }, {
    t("\\left["),
    i(1),
    t("\\right]"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "lr}",
    name = "Left/right curlies",
    wordTrig = false,
  }, {
    t("\\left\\{"),
    i(1),
    t("\\right\\}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "lr>",
    name = "Left/right angles",
    wordTrig = false,
  }, {
    t("\\left<"),
    i(1),
    t("\\right>"),
  }, {
    condition = in_mathzone,
  }),

  -- Selection based

  s({
    trig = "UB",
    name = "Underbrace",
    wordTrig = false,
  }, {
    t("\\underbrace{ "),
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
    t(" }_{ "),
    i(2),
    t(" }"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "US",
    name = "Underset",
    wordTrig = false,
  }, {
    t("\\underset{ "),
    i(1),
    t(" }{ "),
    d(2, function(_, snip)
      local res, env = {}, snip.env
      if env.LS_SELECT_RAW[1] ~= nil then
        for _, ele in ipairs(env.LS_SELECT_RAW) do
          table.insert(res, ele)
        end
        return sn(nil, t(res))
      end
      return sn(nil, i(1))
    end),
    t(" }"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "CA",
    name = "Cancel",
    wordTrig = false,
  }, {
    t("\\cancel{ "),
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
    t(" }"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "CT",
    name = "Cancel to",
    wordTrig = false,
  }, {
    t("\\cancelto{ "),
    i(1),
    t(" }{ "),
    d(2, function(_, snip)
      local res, env = {}, snip.env
      if env.LS_SELECT_RAW[1] ~= nil then
        for _, ele in ipairs(env.LS_SELECT_RAW) do
          table.insert(res, ele)
        end
        return sn(nil, t(res))
      end
      return sn(nil, i(1))
    end),
    t(" }"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "sq",
    name = "Square root",
    wordTrig = false,
  }, {
    t("\\sqrt{ "),
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
    t(" }"),
  }, {
    condition = in_mathzone,
  }),

  -- Misc

  s(
    {
      trig = ":(%l)",
      name = "Vector",
      regTrig = true,
      wordTrig = false,
    },
    f(function(_, snip)
      return "\\vec{" .. snip.captures[1] .. "}"
    end, {}),
    {
      condition = in_mathzone,
    }
  ),
  s({
    trig = "//",
    name = "Fraction",
    wordTrig = false,
  }, {
    t("\\frac{"),
    i(1),
    t("}{"),
    i(2),
    t("}"),
  }, {
    condition = in_mathzone,
    callbacks = {
      [-1] = {
        [events.leave] = function()
          vim.defer_fn(expand_surrounding_delims, 100)
        end,
      },
    },
  }),
  s({
    trig = "([%w\\]+)/",
    name = "Fraction",
    regTrig = true,
    wordTrig = false,
  }, {
    t("\\frac{"),
    f(function(_, snip)
      return snip.captures[1]
    end),
    t("}{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
    callbacks = {
      [-1] = {
        [events.leave] = function()
          vim.defer_fn(expand_surrounding_delims, 100)
        end,
      },
    },
  }),
}

-- At signs
for k, v in pairs(at_signs) do
  table.insert(
    autosnippets,
    s(
      {
        trig = k,
        name = v,
        wordTrig = false,
      },
      t(v),
      {
        condition = in_mathzone,
      }
    )
  )
end

-- Degree functions
for k, _ in pairs(degree_functions) do
  table.insert(
    autosnippets,
    s(
      {
        trig = "([^\\])(" .. k .. ")",
        name = k,
        regTrig = true,
        wordTrig = false,
      },
      f(function(_, snip)
        return snip.captures[1] .. "\\" .. snip.captures[2]
      end),
      {
        condition = in_mathzone,
      }
    )
  )
end

for k, _ in pairs(arc_functions) do
  table.insert(
    autosnippets,
    s(
      {
        trig = "([^\\])(" .. k .. ")",
        name = k,
        regTrig = true,
        wordTrig = false,
        priority = 1001,
      },
      f(function(_, snip)
        return snip.captures[1] .. "\\" .. snip.captures[2]
      end),
      {
        condition = in_mathzone,
      }
    )
  )
end

for k, _ in pairs(degree_functions) do
  table.insert(
    autosnippets,
    s(
      {
        trig = "^(" .. k .. ")",
        name = k .. " (Start of line)",
        regTrig = true,
        wordTrig = false,
      },
      f(function(_, snip)
        return "\\" .. snip.captures[1]
      end),
      {
        condition = in_mathzone,
      }
    )
  )
end

for k, _ in pairs(arc_functions) do
  table.insert(
    autosnippets,
    s(
      {
        trig = "^(" .. k .. ")",
        name = k .. " (Start of line)",
        regTrig = true,
        wordTrig = false,
        priority = 1001,
      },
      f(function(_, snip)
        return "\\" .. snip.captures[1]
      end),
      {
        condition = in_mathzone,
      }
    )
  )
end

local non_autosnippets = {
  s({
    trig = "te",
    name = "Text env",
    wordTrig = false,
  }, {
    t("\\text{"),
    i(1),
    t("}"),
  }, {
    condition = in_mathzone,
  }),
  s({
    trig = "begin",
    name = "Environment (not auto)",
    wordTrig = false,
  }, {
    t("\\begin{"),
    i(1),
    t({ "}", "" }),
    t("\t"),
    d(2, function(_, snip)
      local res, env = {}, snip.env
      if env.LS_SELECT_RAW[1] ~= nil then
        for _, ele in ipairs(env.LS_SELECT_RAW) do
          table.insert(res, ele)
        end
        return sn(nil, t(res))
      end
      return sn(nil, i(1))
    end),
    t({ "", "\\end{" }),
    f(function(args)
      return args[1][1]
    end, { 1 }),
    t("}"),
  }),
  s({
    trig = "aligns",
    name = "Align*",
    wordTrig = true,
  }, {
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
  }, {
    condition = not_in_mathzone,
  }),
}

-- Add space after degree function, except for h

for k, _ in pairs(degree_functions) do
  table.insert(
    autosnippets,
    s(
      {
        trig = "(\\" .. k .. ")([^h%A])",
        name = k,
        regTrig = true,
        wordTrig = false,
      },
      f(function(_, snip)
        return snip.captures[1] .. " " .. snip.captures[2]
      end),
      {
        condition = in_mathzone,
      }
    )
  )
end

for k, _ in pairs(arc_functions) do
  table.insert(
    autosnippets,
    s(
      {
        trig = "(\\" .. k .. ")([^h%A])",
        name = k,
        regTrig = true,
        wordTrig = false,
      },
      f(function(_, snip)
        return snip.captures[1] .. " " .. snip.captures[2]
      end),
      {
        condition = in_mathzone,
      }
    )
  )
end

-- Add space after degree-h functions

for k, _ in pairs(degree_functions) do
  table.insert(
    autosnippets,
    s(
      {
        trig = "(\\" .. k .. "h)(%a)",
        name = k,
        regTrig = true,
        wordTrig = false,
      },
      f(function(_, snip)
        return snip.captures[1] .. " " .. snip.captures[2]
      end),
      {
        condition = in_mathzone,
      }
    )
  )
end

for k, _ in pairs(arc_functions) do
  table.insert(
    autosnippets,
    s(
      {
        trig = "(\\" .. k .. "h)(%a)",
        name = k,
        regTrig = true,
        wordTrig = false,
      },
      f(function(_, snip)
        return snip.captures[1] .. " " .. snip.captures[2]
      end),
      {
        condition = in_mathzone,
      }
    )
  )
end

return non_autosnippets, autosnippets
