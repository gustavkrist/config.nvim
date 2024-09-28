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
  },
}
