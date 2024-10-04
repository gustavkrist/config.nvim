vim.opt.guifont = "FiraCode Nerd Font:h14"
vim.g.neovide_transparency = 0.8
vim.g.neovide_position_animation_length = 0.05
-- vim.g.neovide_scroll_animation_length = 0.15
-- vim.g.neovide_cursor_animation_length = 0.09
vim.g.neovide_scroll_animation_length = 0
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animate_in_insert_mode = false

vim.keymap.set(
  "i",
  "<C-S-v>",
  "<C-o>:set paste<cr>a<c-r>+<cr><C-o>:set nopaste<cr>mi`[=`]`ia",
  { noremap = false, silent = true }
)
vim.keymap.set("!", "<C-S-v>", "<C-R>+", { noremap = true, silent = true })
vim.keymap.set("t", "<C-S-v>", "<C-\\><C-n>pi", { noremap = false, silent = true })
vim.keymap.set({ "v", "n" }, "<C-S-v>", '"+gP', { noremap = true, silent = true })
