-- Big files
vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, buf)
        return vim.bo[buf]
            and vim.bo[buf].filetype ~= "bigfile"
            and path
            and vim.fn.getfsize(path) > (1024 * 1024 * 1.5) -- 1.5MB
            and "bigfile"
            or nil
      end,
    },
  },
})

local definitions = {
  {
    "TextYankPost",
    {
      callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
      end,
    },
  },
  -- Check if we need to reload the file when it changed
  {
    { "FocusGained", "TermClose", "TermLeave" },
    {
      callback = function()
        if vim.o.buftype ~= "nofile" then
          vim.cmd("checktime")
        end
      end,
    },
  },
  -- resize splits if window got resized
  {
    "VimResized",
    {
      callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
      end,
    },
  },
  {
    "FileType",
    {
      pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
      end,
    },
  },
  -- Close some filestypes with <q>
  {
    "FileType",
    {
      pattern = {
        "PlenaryTestPopup",
        "grug-far",
        "help",
        "lspinfo",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "neotest-output",
        "checkhealth",
        "neotest-summary",
        "neotest-output-panel",
        "dbout",
        "gitsigns.blame",
      },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", {
          buffer = event.buf,
          silent = true,
          desc = "Quit buffer",
        })
      end,
    },
  },
  {
    "FileType",
    {
      pattern = "bigfile",
      callback = function(ev)
        vim.schedule(function()
          vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
        end)
      end,
    },
  },
  { -- taken from AstroNvim
    "BufEnter",
    {
      group = "_dir_opened",
      nested = true,
      callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        local stat = vim.loop.fs_stat(bufname)
        local is_directory = stat and stat.type == "directory" or false
        if is_directory then
          vim.api.nvim_del_augroup_by_name("_dir_opened")
          vim.cmd("do User DirOpened")
          vim.api.nvim_exec_autocmds(args.event, { buffer = args.buf, data = args.data })
        end
      end,
    },
  },
  { -- taken from AstroNvim
    { "BufRead", "BufWinEnter", "BufNewFile" },
    {
      group = "_file_opened",
      nested = true,
      callback = function(args)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
        if not (vim.fn.expand("%") == "" or buftype == "nofile") then
          vim.api.nvim_del_augroup_by_name("_file_opened")
          vim.api.nvim_exec_autocmds("User", { pattern = "FileOpened" })
        end
      end,
    },
  },
  {
    "Colorscheme",
    {
      pattern = { "nord" },
      callback = function()
        vim.cmd([[
        hi @markup.heading.1.markdown guifg=#D08770
        hi RenderMarkdownH1Bg guifg=#D08770 guibg=#3d3c44
        hi @markup.heading.2.markdown guifg=#EBCB8B
        hi RenderMarkdownH2Bg guifg=#EBCB8B guibg=#3f4247
        hi @markup.heading.3.markdown guifg=#A3BE8C
        hi RenderMarkdownH3Bg guifg=#A3BE8C guibg=#394147
        hi @markup.heading.4.markdown guifg=#81A1C1
        hi RenderMarkdownH4Bg guifg=#81A1C1 guibg=#363e4c
        hi @markup.heading.5.markdown guifg=#B48EAD
        hi RenderMarkdownH5Bg guifg=#B48EAD guibg=#3a3c4a
        hi @markup.heading.6.markdown guifg=#D8DEE9
        hi RenderMarkdownH6Bg guifg=#D8DEE9 guibg=#3d434f
        hi! link NoiceLspProgressTitle @comment
        ]])
      end,
    }
  },
}

-- Taken from LunarVim
for _, entry in ipairs(definitions) do
  local event = entry[1]
  local opts = entry[2]
  if type(opts.group) == "string" and opts.group ~= "" then
    local exists, _ = pcall(vim.api.nvim_get_autocmds, { group = opts.group })
    if not exists then
      vim.api.nvim_create_augroup(opts.group, {})
    end
  end
  vim.api.nvim_create_autocmd(event, opts)
end
