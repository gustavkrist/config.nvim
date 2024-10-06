return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    init = function()
      if os.getenv("WSL_DISTRO_NAME") ~= nil then
        vim.g.browser = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
      elseif vim.loop.os_uname().sysname == "Darwin" then
        vim.cmd([[
        function! ChromeUrl(url)
          call system("osascript " . $HOME . "/scripts/chrome_new_window.scpt " . a:url)
        endfunction
        ]])
        vim.g.mkdp_browserfunc = "ChromeUrl"
      end
      vim.g.mkdp_filetypes = { "markdown", "pandoc" }
      vim.cmd([[
      let g:mkdp_preview_options = {
          \ 'mkit': {},
          \ 'katex': {'macros': {
            \ "\\Xn": "X_1, \\ldots, X_n",
            \ "\\abs": "\\lvert #1 \\rvert",
            \ "\\ber": "\\operatorname{Ber}",
            \ "\\bin": "\\operatorname{Bin}",
            \ "\\ceil": "\\lceil #1 \\rceil",
            \ "\\cov": "\\operatorname{Cov}",
            \ "\\diff": "\\mathop{}\\!\\mathrm{d}",
            \ "\\expdist": "\\operatorname{Exp}",
            \ "\\expect": "\\operatorname{E}",
            \ "\\floor": "\\lfloor #1 \\rfloor",
            \ "\\geo": "\\operatorname{Geo}",
            \ "\\given": "\\,\\vert\\,",
            \ "\\inv": "#1^{\\text{inv}}",
            \ "\\mean": "\\overline{#1}",
            \ "\\med": "\\operatorname{Med}",
            \ "\\normdist": "\\operatorname{N}",
            \ "\\prob": "\\operatorname{P}",
            \ "\\unif": "\\operatorname{U}",
            \ "\\var": "\\operatorname{Var}",
            \ "\\xn": "x_1, \\ldots, x_n"
            \ }},
          \ 'uml': {},
          \ 'maid': {},
          \ 'disable_sync_scroll': 0,
          \ 'sync_scroll_type': 'middle',
          \ 'hide_yaml_meta': 1,
          \ 'sequence_diagrams': {},
          \ 'flowchart_diagrams': {},
          \ 'content_editable': v:false,
          \ 'disable_filename': 0,
          \ 'toc': {}
          \ }
      ]])
      vim.g.mkdp_markdown_css = os.getenv("HOME") .. "/.config/nvim/styles/markdown-preview.css"
    end,
    ft = { "markdown", "pandoc" },
  },
  {
    "epwalsh/obsidian.nvim",
    ft = "markdown",
    config = function(_, opts)
      local function paste_image()
        vim.ui.input({
          prompt = "Image name",
          default = string.format("pasted-image-%s", os.time())
        }, function(input)
          local cur_dir = vim.api.nvim_buf_get_name(0):match("(.*)/")
          local path = vim.fs.joinpath(cur_dir, "attachments", input)
          vim.cmd(string.format("ObsidianPasteImg %s", path))
        end)
      end
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.keymap.set("n", "<leader>op", paste_image, { desc = "Paste image from clipboard", buffer = 0 })
        end
      })
      require("obsidian").setup(opts)
    end,
    opts = {
      workspaces = {
        {
          name = "School notes",
          path = "~/obsidian-vaults/notes",
        },
      },
      new_notes_location = "current_dir",
      ui = {
        enable = false,
      },
      attachments = {
        confirm_img_paste = false,
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format("![[%s]]", path.name)
        end,
      }
    },
  },
  {
    "vim-pandoc/vim-pandoc",
    init = function()
      vim.g["pandoc#filetypes#pandoc_markdown"] = 0
      vim.g["pandoc#filetypes#handled"] = { "pandoc", "markdown" }
      vim.g["pandoc#folding#fold_yaml"] = 1
      vim.g["pandoc#folding#fold_fenced_codeblocks"] = 1
      vim.g["pandoc#folding#fastfolds"] = 1
      vim.g["pandoc#folding#fdc"] = 0
      -- vim.g["pandoc#modules#enabled"] = { "keyboard" }
      -- vim.g["pandoc#modules#disabled"] = { "formatting", "folding", "hypertext" }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          -- vim.call("pandoc#command#Init")
          -- vim.call("pandoc#compiler#Init")
          vim.call("pandoc#folding#Init")
          vim.call("pandoc#keyboard#Init")
          -- vim.call("pandoc#formatting#Init")
          -- vim.call("pandoc#spell#Init")
          vim.call("pandoc#toc#Init")
          vim.call("pandoc#yaml#Init")
        end,
      })
    end,
  },
  {
    "bullets-vim/bullets.vim",
    init = function()
      vim.g.bullets_outline_levels = { "ROM", "ABC", "num", "abc", "rom", "std-" }
    end,
    ft = "markdown",
  },
  {
    "jmbuhr/otter.nvim",
    config = function(_, opts)
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = "markdown",
        callback = function()
          vim.keymap.set("n", "<leader>oa", function()
            require("otter").activate()
          end, { desc = "Activate otter", buffer = 0 })
          vim.keymap.set("n", "<leader>od", function()
            require("otter").deactivate()
          end, { desc = "Deactivate otter", buffer = 0 })
        end
      })
      require("otter").setup(opts)
    end,
    opts = {},
    version = "*",
    ft = { "markdown" },
  },
  {
    "dhruvasagar/vim-table-mode",
    init = function()
      vim.g.table_mode_map_prefix = "<localleader>t"
    end,
    ft = { "markdown" },
  },
  {
    "3rd/image.nvim",
    dependencies = {
      "kiyoon/magick.nvim",
    },
    opts = {
      integrations = {
        markdown = {
          clear_in_insert_mode = true,
          only_render_image_at_cursor = true,
          resolve_image_path = function(document_path, image_path, fallback)
            local direct_path = vim.fs.joinpath(document_path, image_path)
            if vim.fn.filereadable(direct_path) == 1 then
              return direct_path
            end
            local attachments_path =
                vim.fs.joinpath(document_path:match("(.*)/"), "attachments", image_path:match("[^#|]+"))
            if vim.fn.filereadable(attachments_path) == 1 then
              return attachments_path
            end
            return fallback(document_path, image_path)
          end,
        },
      },
    },
    ft = "markdown",
    cond = (not require("util.firenvim")()) and vim.fn.executable("magick") == 1
  },
  {
    "OXY2DEV/markview.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    opts = {
      hybrid_modes = { "n" },
    },
    ft = "markdown",
  },
}
