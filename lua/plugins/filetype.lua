return {
  {
    "lervag/vimtex",
    init = function()
      if vim.loop.os_uname().sysname == "Linux" then
        if vim.loop.os_uname().release:match("WSL2$") ~= nil then
          vim.g.vimtex_view_method = "general"
          vim.g.vimtex_view_general_viewer = "sumatrapdf"
        else
          vim.g.vimtex_view_method = "zathura"
        end
      elseif vim.loop.os_uname().sysname == "Darwin" then
        vim.g.vimtex_view_method = "skim"
      end
      vim.g.vimtex_format_enabled = 1
    end,
    -- ft = { "markdown", "tex", "latex" },
  },
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
    "luk400/vim-jukit",
    lazy = true,
    ft = { "python" },
    cond = function()
      return os.getenv("NVIM_CONFIG_ENABLE_JUKIT") ~= nil
    end,
    init = function()
      vim.g.jukit_mappings = 0
      require("config.vim_jukit").config()
    end,
  },
  {
    "ionide/Ionide-vim",
    init = function()
      vim.cmd("let g:fsharp#lsp_auto_setup = 0")
      vim.cmd("let g:fsharp#exclude_project_directories = ['paket-files']")
    end,
    ft = { "fsharp" },
  },
  {
    "windwp/nvim-ts-autotag",
    event = "User FileOpened",
    opts = {},
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {},
    ft = "markdown",
    -- Install pip package pylatexenc
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    version = "*",
  },
  {
    "epwalsh/obsidian.nvim",
    ft = "markdown",
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
    },
  },
  {
    "vim-pandoc/vim-pandoc",
    init = function()
      vim.g["pandoc#filetypes#handled"] = { "pandoc", "markdown" }
      vim.g["pandoc#folding#fold_yaml"] = 1
      vim.g["pandoc#folding#fold_fenced_codeblocks"] = 1
      vim.g["pandoc#folding#fastfolds"] = 1
      vim.g["pandoc#folding#fdc"] = 0
      vim.g["pandoc#filetypes#pandoc_markdown"] = 0
      -- vim.g["pandoc#modules#enabled"] = { "keyboard" }
      -- vim.g["pandoc#modules#disabled"] = { "formatting", "folding", "hypertext" }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          -- vim.call("pandoc#command#Init")
          -- vim.call("pandoc#compiler#Init")
          vim.call("pandoc#folding#Init")
          -- vim.call("pandoc#formatting#Init")
          vim.call("pandoc#keyboard#Init")
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
  },
}
