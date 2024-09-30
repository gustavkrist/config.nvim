return {
  {
    "L3MON4D3/LuaSnip",
    -- dependencies = {
    --   { "rafamadriz/friendly-snippets", lazy = true },
    -- },
    config = function(_, opts)
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { "./lua/luasnippets" },
        fs_event_providers = {
          autocmd = false,
          libuv = true,
        },
      })
      -- require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip").filetype_extend("latex", { "tex" })
      require("luasnip").filetype_extend("markdown_inline", { "markdown" })
      require("luasnip").setup(opts)
    end,
    opts = function()
      local types = require("luasnip.util.types")
      return {
        enable_autosnippets = true,
        store_selection_keys = "<Tab>",
        ft_func = require("luasnip.extras.filetype_functions").from_pos_or_filetype,
        load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft({
          markdown = { "tex", "sql", "python", "vue" },
        }),
        ext_opts = {
          [types.choiceNode] = {
            active = {
              virt_text = {{"●", "@comment.warning"}},
            },
          },
          [types.insertNode] = {
            active = {
              virt_text = {{"●", "@boolean"}},
            },
          },
        },
      }
    end,
    version = "v2.*",
    build = "make install_jsregexp",
    event = "InsertEnter",
    keys = {
      { "<C-n>", "<Plug>luasnip-next-choice", mode = "i" },
      { "<C-n>", "<Plug>luasnip-next-choice", mode = "s" },
      { "<C-p>", "<Plug>luasnip-prev-choice", mode = "i" },
      { "<C-p>", "<Plug>luasnip-prev-choice", mode = "s" },
      { "<C-u>", "<cmd>lua require('luasnip.extras.select_choice')()<cr>", mode = "i" },
      { "<C-u>", "<cmd>lua require('luasnip.extras.select_choice')()<cr>", mode = "s" },
      { "<leader>se", "<cmd>lua require('luasnip.loaders').edit_snippet_files()<CR>", desc = "Edit snippets" },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp", lazy = true },
      { "hrsh7th/cmp-buffer", lazy = true },
      { "hrsh7th/cmp-path", lazy = true },
      { "hrsh7th/cmp-cmdline", lazy = true },
      { "hrsh7th/cmp-nvim-lua", lazy = true },
      { "saadparwaiz1/cmp_luasnip", lazy = true },
      "L3MON4D3/LuaSnip",
    },
    config = function(_, opts)
      local cmp = require("cmp")
      cmp.setup(opts)
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
    end,
    opts = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local cmp_util = require("util.cmp")
      return {
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
                vim.b[bufnr]._vue_ts_cached_is_in_start_tag = cmp_util.is_in_start_tag()
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
          format = function(entry, vim_item)
            -- Kind icons
            icon, _, _ = require("mini.icons").get("lsp", vim_item.kind)
            vim_item.kind = string.format("%s", icon)
            -- vim_item.kind = string.format("%s %s", icon, vim_item.kind) -- This concatonates the icons with the name of the item kind
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
            -- elseif cmp_util.jumpable(1) then
            --   luasnip.jump(1)
            -- elseif vim.bo.filetype == "tex" then
            --   cmp_util.seek_delim(fallback)
            elseif cmp_util.has_words_before() then
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
      }
    end,
    event = { "InsertEnter", "CmdlineEnter" },
  },
}
