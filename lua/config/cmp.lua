local M = {}

local status_cmp_ok, cmp = pcall(require, "cmp")
if not status_cmp_ok then
  return
end
local status_luasnip_ok, luasnip = pcall(require, "luasnip")
if not status_luasnip_ok then
  return
end

local kind_icons = require("util.icons").kind

local function jumpable(dir)
  local win_get_cursor = vim.api.nvim_win_get_cursor
  local get_current_buf = vim.api.nvim_get_current_buf

  ---sets the current buffer's luasnip to the one nearest the cursor
  ---@return boolean true if a node is found, false otherwise
  local function seek_luasnip_cursor_node()
    -- TODO(kylo252): upstream this
    -- for outdated versions of luasnip
    if not luasnip.session.current_nodes then
      return false
    end

    local node = luasnip.session.current_nodes[get_current_buf()]
    if not node then
      return false
    end

    local snippet = node.parent.snippet
    local exit_node = snippet.insert_nodes[0]

    local pos = win_get_cursor(0)
    pos[1] = pos[1] - 1

    -- exit early if we're past the exit node
    if exit_node then
      local exit_pos_end = exit_node.mark:pos_end()
      if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    node = snippet.inner_first:jump_into(1, true)
    while node ~= nil and node.next ~= nil and node ~= snippet do
      local n_next = node.next
      local next_pos = n_next and n_next.mark:pos_begin()
      local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
        or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

      -- Past unmarked exit node, exit early
      if n_next == nil or n_next == snippet.next then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end

      if candidate then
        luasnip.session.current_nodes[get_current_buf()] = node
        return true
      end

      local ok
      ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
      if not ok then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    -- No candidate, but have an exit node
    if exit_node then
      -- to jump to the exit node, seek to snippet
      luasnip.session.current_nodes[get_current_buf()] = snippet
      return true
    end

    -- No exit node, exit from snippet
    snippet:remove_from_jumplist()
    luasnip.session.current_nodes[get_current_buf()] = nil
    return false
  end

  if dir == -1 then
    return luasnip.in_snippet() and luasnip.jumpable(-1)
  else
    return luasnip.in_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable(1)
  end
end

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function seek_delim(fallback)
  local math_delims = vim.fn["vimtex#delim#get_surrounding"]("delim_math")
  local math_right = math_delims[2]
  local tex_delims = vim.fn["vimtex#delim#get_surrounding"]("delim_tex")
  local tex_right = tex_delims[2]
  local right
  if math_right["delim"] ~= nil or tex_right["delim"] then
    if math_right["delim"] ~= nil and tex_right["delim"] ~= nil then
      if math_right["lnum"] < tex_right["lnum"] then
        right = math_right
      elseif math_right["lnum"] > tex_right["lnum"] then
        right = tex_right
      else
        if math_right["cnum"] < tex_right["cnum"] then
          right = math_right
        elseif math_right["cnum"] > tex_right["cnum"] then
          right = tex_right
        else
          right = math_right
        end
      end
    elseif math_right["delim"] ~= nil then
      right = math_right
    elseif tex_right["delim"] ~= nil then
      right = tex_right
    end
    local cursor = { right["lnum"], right["cnum"] }
    vim.api.nvim_win_set_cursor(0, cursor)
  else
    fallback()
  end
end

local is_in_start_tag = function()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return false
  end
  local nodes_to_check = { "start_tag", "self_closing_tag", "directive_attribute" }
  return vim.tbl_contains(nodes_to_check, node:type())
end

M.setup = function()
  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    sources = cmp.config.sources({
      {
        name = "nvim_lsp",
        entry_filter = function(entry, ctx)
          if ctx.filetype ~= "vue" then
            return true
          end
          -- Use a buffer-local variable to cache the result of the Treesitter check
          local bufnr = ctx.bufnr
          local cached_is_in_start_tag = vim.b[bufnr]._vue_ts_cached_is_in_start_tag
          if cached_is_in_start_tag == nil then
            vim.b[bufnr]._vue_ts_cached_is_in_start_tag = is_in_start_tag()
          end
          -- If not in start tag, return true
          if vim.b[bufnr]._vue_ts_cached_is_in_start_tag == false then
            return true
          end
          local cursor_before_line = ctx.cursor_before_line
          -- For events
          if cursor_before_line:sub(-1) == "@" then
            return entry.completion_item.label:match("^@")
          -- For props also exclude events with `:on-` prefix
          elseif cursor_before_line:sub(-1) == ":" then
            return entry.completion_item.label:match("^:") and not entry.completion_item.label:match("^:on%-")
          else
            return true
          end
        end,
      },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "nvim_lua" },
      { name = "path" },
    }),
    formatting = {
      fields = { "kind", "abbr", "menu" },
      max_width = 0,
      kind_icons = kind_icons,
      format = function(entry, vim_item)
        -- Kind icons
        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
        -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
          path = "[Path]",
        })[entry.source.name]
        vim_item.dup = ({
          buffer = 1,
          path = 1,
          nvim_lsp = 0,
          luasnip = 1,
        })[entry.source.name] or 0
        return vim_item
      end,
    },
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    window = {
      completion = require("cmp.config.window").bordered(),
      documentation = require("cmp.config.window").bordered(),
    },
    completion = {
      autocomplete = {
        require("cmp.types").cmp.TriggerEvent.TextChanged,
      },
      keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
      keyword_length = 1,
    },
    mapping = {
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
      ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-y>"] = cmp.mapping({
        i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        c = function(fallback)
          if cmp.visible() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end,
      }),
      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
      ["<C-e>"] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        elseif cmp.visible() then
          cmp.select_next_item()
        elseif jumpable(1) then
          luasnip.jump(1)
        elseif vim.bo.filetype == "tex" then
          seek_delim(fallback)
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        elseif cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i", "s" }),
      -- Accept currently selected item. If none selected, `select` first item.
      -- Set `select` to `false` to only confirm explicitly selected items.
      ["<CR>"] = cmp.mapping(function(fallback)
        local ConfirmBehavior = require("cmp.types").cmp.ConfirmBehavior
        if cmp.visible() then
          local confirm_opts = {
            behavior = ConfirmBehavior.Replace,
            select = false,
          }

          local is_insert_mode = function()
            return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
          end
          if is_insert_mode() then -- prevent overwriting brackets
            confirm_opts.behavior = ConfirmBehavior.Insert
          end
          local entry = cmp.get_selected_entry()
          local is_copilot = entry and entry.source.name == "copilot"
          if is_copilot then
            confirm_opts.behavior = ConfirmBehavior.Replace
            confirm_opts.select = true
          end
          if cmp.confirm(confirm_opts) then
            return -- success, exit early
          end
        end
        -- if jumpable(1) and luasnip.jump(1) then
        --   return -- success, exit early
        -- end
        fallback() -- if not exited early, always fallback
      end),
    },
  })

  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
    matching = { disallow_symbol_nonprefix_matching = false },
  })

  cmp.event:on("menu_closed", function()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.b[bufnr]._vue_ts_cached_is_in_start_tag = nil
  end)
end
return M
