local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local toggle = require("util.toggle")

local setup = {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = false, -- adds help for motions
      text_objects = false, -- help for text objects triggered after entering an operator
      windows = false, -- default bindings on <c-w>
      nav = false, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
  defaults = {
    delay = 100,
  },
  -- add operators that will trigger motion and text object completion
  -- to enable all native operators, set the preset / operators plugin above
  -- operators = { gc = "Comments" },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  show_help = true, -- show help message on the command line when the popup is visible
}

local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

local function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end

local function get_project_root()
  return require("util.root")()
  -- local git_root_dirs = vim.fn.systemlist("git rev-parse --show-toplevel")
  -- if vim.v.shell_error == 0 then
  --   return git_root_dirs[1]
  -- else
  --   local active_clients = vim.lsp.get_active_clients()
  --   if next(active_clients) ~= nil then
  --     return active_clients[1].config.root_dir
  --   end
  -- end
  -- return nil
end

function grug_project_root()
  local grug = require("grug-far")
  -- local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = {
      paths = get_project_root(),
      -- filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  })
end

local function telescope_project_root(picker, opts)
  opts = opts or {}
  local project_root = get_project_root()
  if project_root ~= nil then
    opts.cwd = project_root
  end
  require("telescope.builtin")[picker](opts)
end

local function telescope_find_files_project_root(opts)
  opts = opts or {}
  local git_files_ok, _ = pcall(require("telescope.builtin").git_files)
  if not git_files_ok then
    local active_clients = vim.lsp.get_active_clients()
    if next(active_clients) ~= nil then
      opts.cwd = active_clients[1].config.root_dir
    end
    require("telescope.builtin").find_files(opts)
  end
end

local telescope_project_root_ivy = function(picker, opts)
  opts = opts or {}
  local project_root = get_project_root()
  if project_root ~= nil then
    opts.cwd = project_root
  end
  require("telescope.builtin")[picker](require("telescope.themes").get_ivy(opts))
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

local is_filetype = function(filetype)
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(buf, "filetype")
  return filetype == ft
end

local function minifiles_open_cwd(fresh)
  local path = vim.api.nvim_buf_get_name(0)
  print(path)
  print(vim.fn.filereadable(path) == 1)
  if vim.fn.filereadable(path) == 1 then
    require("mini.files").open(path, fresh)
  else
    require("mini.files").open(path:match("(.*)/"), fresh)
  end
end

local openingh = require("util.git").run_openingh_with_picked_ref

local mappings = {
  {
    mode = "n",
    {
      "<leader>b",
      "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown({previewer = false}))<cr>",
      desc = "Buffers",
    },
    { "<leader>c", "<cmd>bd<cr>", desc = "Close Buffer" },
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
    {
      "<leader>f",
      function()
        telescope_project_root("find_files")
      end,
      desc = "Find files",
    },
    {
      "<leader>F",
      function()
        telescope_project_root_ivy("live_grep")
      end,
      desc = "Search Text",
    },
    { "<leader>h", "<cmd>nohlsearch<cr>", desc = "No Highlight" },
    { "<leader>/", "gcc", desc = "Toggle Comment", noremap = false },
    {
      { "<leader>o", group = "Open in" },
      {
        { "<leader>og", group = "Open in GitHub.." },
        { "<leader>ogr", "<cmd>OpenInGHRepo<cr>", desc = "Open repo in GitHub" },
        {
          "<leader>ogf",
          function()
            openingh("OpenInGHFile")
          end,
          mode = "n",
          desc = "Open file in GitHub",
        },
        {
          "<leader>ogl",
          function()
            openingh("OpenInGHFileLines")
          end,
          mode = "n",
          desc = "Open line(s) in GitHub",
        },
        {
          "<leader>ogl",
          function()
            openingh(":OpenInGHFileLines")
          end,
          mode = "v",
          desc = "Open line(s) in GitHub",
        },
      },
    },
    {
      { "<leader>g", group = "Git" },
      { "<leader>gg", _LAZYGIT_TOGGLE, desc = "Lazygit" },
      {
        "<leader>gj",
        "<cmd>lua require('gitsigns').nav_hunk('next', {navigation_message = false})<cr>",
        desc = "Next Hunk",
      },
      {
        "<leader>gk",
        "<cmd>lua require('gitsigns').nav_hunk('prev', {navigation_message = false})<cr>",
        desc = "Prev Hunk",
      },
      { "<leader>gl", "<cmd>lua require('gitsigns').blame_line()<cr>", desc = "Blame" },
      { "<leader>gL", "<cmd>lua require('gitsigns').blame_line({full=true})<cr>", desc = "Blame Line (full)" },
      { "<leader>gp", "<cmd>lua require('gitsigns').preview_hunk()<cr>", desc = "Preview Hunk" },
      { "<leader>gr", "<cmd>lua require('gitsigns').reset_hunk()<cr>", desc = "Reset Hunk" },
      { "<leader>gR", "<cmd>lua require('gitsigns').reset_buffer()<cr>", desc = "Reset Buffer" },
      { "<leader>gs", "<cmd>lua require('gitsigns').stage_hunk()<cr>", desc = "Stage Hunk" },
      {
        "<leader>gu",
        "<cmd>lua require('gitsigns').undo_stage_hunk()<cr>",
        desc = "Undo Stage Hunk",
      },
      { "<leader>go", "<cmd>Telescope git_status<cr>", desc = "Open changed file" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Checkout commit" },
      {
        "<leader>gC",
        "<cmd>Telescope git_bcommits<cr>",
        desc = "Checkout commit(for current file)",
      },
      { "<leader>bd", "<cmd>Gitsigns diffthis HEAD<cr>", desc = "Git Diff" },
    },
    {
      { "<leader>t", group = "Terminal" },
      { "<leader>tg", _LAZYGIT_TOGGLE, desc = "Lazygit" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float" },
      { "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Horizontal" },
      { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Vertical" },
    },
    {
      { "<leader>l", group = "Lsp" },
      { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
      {
        "<leader>ld",
        "<cmd>Telescope diagnostics bufnr=0<cr>",
        desc = "Document Diagnostics",
      },
      { "<leader>lw", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
      -- { "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format" },
      { "<leader>li", "<cmd>LspInfo<cr>", desc = "Info" },
      {
        "<leader>lj",
        "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>",
        desc = "Next Diagnostic",
      },
      {
        "<leader>lk",
        "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",
        desc = "Prev Diagnostic",
      },
      { "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
      { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason" },
      { "<leader>lq", "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", desc = "Quickfix" },
      { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
      { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
      {
        "<leader>lS",
        "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
        desc = "Workspace Symbols",
      },
    },
    {
      { "<leader>s", group = "Search" },
      { "<leader>sb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
      { "<leader>sc", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },
      { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find File" },
      { "<leader>sg", grug_project_root, mode = { "n", "v" }, desc = "Search and Replace" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Find highlight groups" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sr", "<cmd>Telescope oldfiles<cr>", desc = "Open Recent File" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      -- { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>st", "<cmd>Telescope live_grep<cr>", desc = "Text" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sl", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
      {
        "<leader>sp",
        "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
        desc = "Colorscheme with Preview",
      },
    },
    {
      { "<leader>S", group = "Sessions" },
      { "<leader>Sn", write_new_session, desc = "New session" },
      { "<leader>Ss", "<cmd>lua MiniSessions.select()<cr>", desc = "Select a session" },
      { "<leader>Sw", "<cmd>lua MiniSessions.write()<cr>", desc = "Write current session" },
      { "<leader>Sg", write_git_branch_session, desc = "Write current session (git branch)" },
    },
  },
  { "<leader>/", "gc", desc = "Toggle Comment", mode = "v", noremap = false },
}

which_key.setup(setup)
which_key.add(mappings)

-- Toggles
toggle.map("<leader>ud", toggle.diagnostics)
toggle.map("<leader>us", toggle("spell", { name = "Spelling" }))
toggle.map("<leader>uw", toggle("wrap", { name = "Wrap" }))
toggle.map("<leader>wm", toggle.maximize)
if vim.lsp.inlay_hint then
  toggle.map("<leader>uh", toggle.inlay_hints)
end
