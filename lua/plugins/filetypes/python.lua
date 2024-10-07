return {
  {
    "luk400/vim-jukit",
    lazy = true,
    ft = { "python" },
    cond = function()
      return os.getenv("NVIM_CONFIG_ENABLE_JUKIT") ~= nil
    end,
    init = function()
      local conda = os.getenv("CONDA_PREFIX") or (os.getenv("HOME") .. "/mambaforge")
      vim.g.jukit_mappings = 0
      vim.g.jukit_shell_cmd = conda .. "/bin/ipython3"
      vim.g.jukit_comment_mark = "# "
      vim.g.jukit_mpl_style = vim.fs.joinpath(os.getenv("HOME"), ".config/nvim/styles/backend.mplstyle")
      vim.g.jukit_layout = {
        split = "horizontal",
        p1 = 0.6,
        val = {
          "file_content",
          {
            split = "vertical",
            p1 = 0.6,
            val = { "output", "output_history" },
          },
        },
      }
      vim.cmd([[
        " Splits
        nnoremap <localleader>os :call jukit#splits#output()<cr>
        "   - Opens a new output window and executes the command specified in `g:jukit_shell_cmd`
        nnoremap <localleader>ts :call jukit#splits#term()<cr>
        "   - Opens a new output window without executing any command
        nnoremap <localleader>hs :call jukit#splits#history()<cr>
        "   - Opens a new output-history window, where saved ipython outputs are displayed
        nnoremap <localleader>ohs :call jukit#splits#output_and_history()<cr>
        "   - Shortcut for opening output terminal and output-history
        nnoremap <localleader>hd :call jukit#splits#close_history()<cr>
        "   - Close output-history window
        nnoremap <localleader>od :call jukit#splits#close_output_split()<cr>
        "   - Close output window
        nnoremap <localleader>ohd :call jukit#splits#close_output_and_history(1)<cr>
        "   - Close both windows. Argument: Whether or not to ask you to confirm before closing.
        nnoremap <localleader>so :call jukit#splits#show_last_cell_output(1)<cr>
        "   - Show output of current cell (determined by current cursor position) in output-history window. Argument: Whether or not to reload outputs if cell id of outputs to display is the same as the last cell id for which outputs were displayed
        nnoremap <localleader>j :call jukit#splits#out_hist_scroll(1)<cr>
        "   - Scroll down in output-history window. Argument: whether to scroll down (1) or up (0)
        nnoremap <localleader>k :call jukit#splits#out_hist_scroll(0)<cr>
        "   - Scroll up in output-history window. Argument: whether to scroll down (1) or up (0)
        nnoremap <localleader>ah :call jukit#splits#toggle_auto_hist()<cr>
        "   - Create/delete autocmd for displaying saved output on CursorHold. Also, see explanation for `g:jukit_auto_output_hist`
        nnoremap <localleader>sl :call jukit#layouts#set_layout()<cr>
        "   - Apply layout (see `g:jukit_layout`) to current splits - NOTE: it is expected that this function is called from the main file buffer/split

        " Sending code
        nnoremap <localleader><space> :call jukit#send#section(0)<cr>
        "   - Send code within the current cell to output split (also saves the output if ipython is used and `g:jukit_save_output==1`). Argument: if 1, will move the cursor to the next cell below after sending the code to the split, otherwise cursor position stays the same.
        nnoremap <localleader><cr> :call jukit#send#line()<cr>
        "   - Send current line to output split
        vnoremap <cr> :<C-U>call jukit#send#selection()<cr>
        "   - Send visually selected code to output split
        nnoremap <localleader>cc :call jukit#send#until_current_section()<cr>
        "   - Execute all cells until the current cell
        nnoremap <localleader>all :call jukit#send#all()<cr>
        "   - Execute all cells

        " Cells
        nnoremap <localleader>co :call jukit#cells#create_below(0)<cr>
        "   - Create new code cell below. Argument: Whether to create code cell (0) or markdown cell (1)
        nnoremap <localleader>cO :call jukit#cells#create_above(0)<cr>
        "   - Create new code cell above. Argument: Whether to create code cell (0) or markdown cell (1)
        nnoremap <localleader>ct :call jukit#cells#create_below(1)<cr>
        "   - Create new textcell below. Argument: Whether to create code cell (0) or markdown cell (1)
        nnoremap <localleader>cT :call jukit#cells#create_above(1)<cr>
        "   - Create new textcell above. Argument: Whether to create code cell (0) or markdown cell (1)
        nnoremap <localleader>cd :call jukit#cells#delete()<cr>
        "   - Delete current cell
        nnoremap <localleader>cs :call jukit#cells#split()<cr>
        "   - Split current cell (saved output will then be assigned to the resulting cell above)
        nnoremap <localleader>cM :call jukit#cells#merge_above()<cr>
        "   - Merge current cell with the cell above
        nnoremap <localleader>cm :call jukit#cells#merge_below()<cr>
        "   - Merge current cell with the cell below
        nnoremap <localleader>ck :call jukit#cells#move_up()<cr>
        "   - Move current cell up
        nnoremap <localleader>cj :call jukit#cells#move_down()<cr>
        "   - Move current cell down
        nnoremap <localleader>J :call jukit#cells#jump_to_next_cell()<cr>
        "   - Jump to the next cell below
        nnoremap <localleader>K :call jukit#cells#jump_to_previous_cell()<cr>
        "   - Jump to the previous cell above
        nnoremap <localleader>ddo :call jukit#cells#delete_outputs(0)<cr>
        "   - Delete saved output of current cell. Argument: Whether to delete all saved outputs (1) or only saved output of current cell (0)
        nnoremap <localleader>dda :call jukit#cells#delete_outputs(1)<cr>
        "   - Delete saved outputs of all cells. Argument: Whether to delete all saved outputs (1) or only saved output of current cell (0)

        " ipynb conversion
        nnoremap <localleader>np :call jukit#convert#notebook_convert("jupyter-notebook")<cr>
        "   - Convert from ipynb to py or vice versa. Argument: Optional. If an argument is specified, then its value is used to open the resulting ipynb file after converting script.
        nnoremap <localleader>ht :call jukit#convert#save_nb_to_file(0,1,'html')<cr>
        "   - Convert file to html (including all saved outputs) and open it using the command specified in `g:jukit_html_viewer'. If `g:jukit_html_viewer` is not defined, then will default to `g:jukit_html_viewer='xdg-open'`. Arguments: 1.: Whether to rerun all cells when converting 2.: Whether to open it after converting 3.: filetype to convert to
        nnoremap <localleader>rht :call jukit#convert#save_nb_to_file(1,1,'html')<cr>
        "   - same as above, but will (re-)run all cells when converting to html
        nnoremap <localleader>pd :call jukit#convert#save_nb_to_file(0,1,'pdf')<cr>
        "   - Convert file to pdf (including all saved outputs) and open it using the command specified in `g:jukit_pdf_viewer'. If `g:jukit_pdf_viewer` is not defined, then will default to `g:jukit_pdf_viewer='xdg-open'`. Arguments: 1.: Whether to rerun all cells when converting 2.: Whether to open it after converting 3.: filetype to convert to
        nnoremap <localleader>rpd :call jukit#convert#save_nb_to_file(1,1,'pdf')<cr>
        "   - same as above, but will (re-)run all cells when converting to pdf
      ]])
    end,
  },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    lazy = true,
    cmd = { "VenvSelect" },
    branch = "regexp", -- This is the regexp branch, use this for the new version
    config = function(_, opts)
      vim.api.nvim_create_autocmd({ "FileType" },
        {
          pattern = "python",
          callback = function()
            vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<cr>",
              { desc = "Select VirtualEnv", silent = true, noremap = true, buffer = 0 })
            vim.keymap.set(
              "n",
              "<leader>vd",
              "<cmd>lua require('venv-selector').deactivate()<cr>",
              { desc = "Deactivate VirtualEnv", silent = true, noremap = true, buffer = 0 }
            )
          end,
        }
      )
      require("venv-selector").setup(opts)
    end,
    opts = {
      settings = {
        search = {
          workspace = false,
          file = false,
          pipx = false,
          cwd = false,
          poetry = false,
          hatch = false,
          virtualenvs = false,
          miniconda_envs = false,
          miniconda_base = false,
          pipenv = false,
        },
      },
    },
  },
  {
    "alexpasmantier/pymple.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- optional (nicer ui)
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    build = ":PympleBuild",
    config = function(_, opts)
      require("pymple").setup(opts)
    end,
    opts = {
      keymaps = {
        resolve_import_under_cursor = {
          desc = "Resolve import unser cursor",
          keys = "<localleader>li",
        },
      },
    },
    event = "VeryLazy",
  },
}
