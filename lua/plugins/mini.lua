-- Mini.ai indent text object
-- For "a", it will include the non-whitespace line surrounding the indent block.
-- "a" is line-wise, "i" is character-wise.
local function ai_indent(ai_type)
  local spaces = (" "):rep(vim.o.tabstop)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local indents = {} ---@type {line: number, indent: number, text: string}[]

  for l, line in ipairs(lines) do
    if not line:find("^%s*$") then
      indents[#indents + 1] = { line = l, indent = #line:gsub("\t", spaces):match("^%s*"), text = line }
    end
  end

  local ret = {}

  for i = 1, #indents do
    if i == 1 or indents[i - 1].indent < indents[i].indent then
      local from, to = i, i
      for j = i + 1, #indents do
        if indents[j].indent < indents[i].indent then
          break
        end
        to = j
      end
      from = ai_type == "a" and from > 1 and from - 1 or from
      to = ai_type == "a" and to < #indents and to + 1 or to
      ret[#ret + 1] = {
        indent = indents[i].indent,
        from = { line = indents[from].line, col = ai_type == "a" and 1 or indents[from].indent + 1 },
        to = { line = indents[to].line, col = #indents[to].text },
      }
    end
  end

  return ret
end

-- taken from MiniExtra.gen_ai_spec.buffer
local function ai_buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line("$")
  if ai_type == "i" then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

-- register all text objects with which-key
---@param opts table
local function ai_whichkey(opts)
  local objects = {
    { " ", desc = "whitespace" },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { "(", desc = "() block" },
    { ")", desc = "() block with ws" },
    { "<", desc = "<> block" },
    { ">", desc = "<> block with ws" },
    { "?", desc = "user prompt" },
    { "U", desc = "use/call without dot" },
    { "[", desc = "[] block" },
    { "]", desc = "[] block with ws" },
    { "_", desc = "underscore" },
    { "`", desc = "` string" },
    { "a", desc = "argument" },
    { "b", desc = ")]} block" },
    { "c", desc = "class" },
    { "d", desc = "digit(s)" },
    { "e", desc = "CamelCase / snake_case" },
    { "f", desc = "function" },
    { "g", desc = "entire file" },
    { "i", desc = "indent" },
    { "o", desc = "block, conditional, loop" },
    { "q", desc = "quote `\"'" },
    { "t", desc = "tag" },
    { "u", desc = "use/call" },
    { "{", desc = "{} block" },
    { "}", desc = "{} with ws" },
  }

  local ret = { mode = { "o", "x" } }
  ---@type table<string, string>
  local mappings = vim.tbl_extend("force", {}, {
    around = "a",
    inside = "i",
    around_next = "an",
    inside_next = "in",
    around_last = "al",
    inside_last = "il",
  }, opts.mappings or {})
  mappings.goto_left = nil
  mappings.goto_right = nil

  for name, prefix in pairs(mappings) do
    name = name:gsub("^around_", ""):gsub("^inside_", "")
    ret[#ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      if prefix:sub(1, 1) == "i" then
        desc = desc:gsub(" with ws", "")
      end
      ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
    end
  end
  require("which-key").add(ret, { notify = false })
end

local write_new_session = function()
  local name = vim.fn.input("Session name: ", "")
  if name ~= "" then
    require("mini.sessions").write(name)
  end
end

local write_git_branch_session = function()
  local name = require("util.git").get_session_name()
  if name ~= nil then
    require("mini.sessions").write(name)
  end
end

local function minifiles_open_cwd(fresh)
  local path = vim.api.nvim_buf_get_name(0)
  if vim.fn.filereadable(path) == 1 then
    require("mini.files").open(path, fresh)
  else
    require("mini.files").open(path:match("(.*)/"), fresh)
  end
end

return {
  {
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
      local ai = require("mini.ai")
      local opts = {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),       -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },           -- tags
          d = { "%f[%d]%d+" },                                                          -- digits
          e = {                                                                         -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          i = ai_indent,                                             -- indent
          g = ai_buffer,                                             -- buffer
          u = ai.gen_spec.function_call(),                           -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
      ai.setup(opts)
      require("util.plugins").on_load("which-key.nvim", function()
        vim.schedule(function()
          ai_whichkey(opts)
        end)
      end)
      require("mini.cursorword").setup()
      require("mini.files").setup({
        windows = {
          preview = true,
          width_preview = 30,
        },
        options = {
          use_as_default_explorer = true,
        },
      })
      require("mini.icons").setup()
      require("mini.operators").setup({
        replace = { prefix = "cr" },
        sort = { prefix = "go" },
      })
      if not require("util.firenvim")() then
        require("mini.sessions").setup()
        require("mini.starter").setup()
      end

      local gen_hook = require("mini.splitjoin").gen_hook
      local curly = { brackets = { '%b{}' } }
      -- Add trailing comma when splitting inside curly brackets
      local add_comma_curly = gen_hook.add_trailing_separator(curly)
      -- Delete trailing comma when joining inside curly brackets
      local del_comma_curly = gen_hook.del_trailing_separator(curly)
      -- Pad curly brackets with single space after join
      local pad_curly = gen_hook.pad_brackets(curly)

      require("mini.splitjoin").setup()
      vim.api.nvim_create_autocmd("FileType",
        {
          pattern = { "lua" },
          group = vim.api.nvim_create_augroup("_splitjoin_filetype", { clear = true }),
          callback = function()
            vim.b.minisplitjoin_config = {
              split = { hooks_post = { add_comma_curly } },
              join  = { hooks_post = { del_comma_curly, pad_curly } },
            }
          end
        })
      vim.api.nvim_exec_autocmds("FileType", { group = "_splitjoin_filetype" })

      require("mini.trailspace").setup()
      -- Sessions
      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        callback = function()
          if require("util.firenvim")() then
            return
          end
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            -- Don't save while there's any 'nofile' buffer open.
            if vim.api.nvim_get_option_value("buftype", { buf = buf }) == "nofile" then
              return
            end
          end
          if vim.v.this_session ~= "" then
            require("mini.sessions").write()
          end
        end,
      })
      require("util.plugins").on_very_lazy(function()
        if require("util.firenvim")() then
          return
        end
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
        if vim.fn.expand("%") == "Starter" and buftype == "nofile" then
          require("util.git").set_git_session_global()
          local function wait()
            if vim.g.git_session_name == nil then
              vim.defer_fn(wait, 50)
              return
            end
            if vim.g.git_session_name ~= "" then
              require("mini.sessions").read(vim.g.git_session_name)
            end
            vim.g.git_session_name = nil
          end
          vim.defer_fn(wait, 50)
        end
      end)
    end,
    keys = function()
      return {
        {
          "<leader>e",
          function()
            minifiles_open_cwd(false)
          end,
          desc = "File Explorer",
        },
        {
          "<leader>E",
          function()
            minifiles_open_cwd(true)
          end,
          desc = "File Explorer (fresh)",
        },
        { "<leader>Sn", write_new_session,                    desc = "New session" },
        { "<leader>Ss", "<cmd>lua MiniSessions.select()<cr>", desc = "Select a session" },
        { "<leader>Sw", "<cmd>lua MiniSessions.write()<cr>",  desc = "Write current session" },
        { "<leader>Sg", write_git_branch_session,             desc = "Write current session (git branch)" },
      }
    end,
    event = "VimEnter",
  },
}
