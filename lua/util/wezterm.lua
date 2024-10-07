local M = {}

-- https://github.com/folke/dot/blob/39602b7edc7222213bce762080d8f46352167434/nvim/lua/util/init.lua#L95C1-L119C1
function M.base64(data)
  data = tostring(data)
  local bit = require("bit")
  local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  local b64, len = "", #data
  local rshift, lshift, bor = bit.rshift, bit.lshift, bit.bor

  for i = 1, len, 3 do
    local a, b, c = data:byte(i, i + 2)
    b = b or 0
    c = c or 0

    local buffer = bor(lshift(a, 16), lshift(b, 8), c)
    for j = 0, 3 do
      local index = rshift(buffer, (3 - j) * 6) % 64
      b64 = b64 .. b64chars:sub(index + 1, index + 1)
    end
  end

  local padding = (3 - len % 3) % 3
  b64 = b64:sub(1, -1 - padding) .. ("="):rep(padding)

  return b64
end

function M.reset_term_colors()
  io.write("\027]104;\a")
end

function M.set_term_background(text, color, cursor)
  io.write(string.format("\027]10;%s;%s;%s\a", text, color, cursor))
end

function M.set_user_var(key, value)
  io.write(string.format("\027]1337;SetUserVar=%s=%s\a", key, M.base64(value)))
end

function M.setup()
  local nav = {
    h = "Left",
    j = "Down",
    k = "Up",
    l = "Right",
  }

  local function navigate(dir)
    return function()
      local win = vim.api.nvim_get_current_win()
      vim.cmd.wincmd(dir)
      local pane = vim.env.WEZTERM_PANE
      local wezterm_prog = "wezterm"
      if vim.fn.has("wsl") then
        wezterm_prog = "wezterm.exe"
        pane = vim.env.TERM == "wezterm"
      end
      if vim.system and pane and win == vim.api.nvim_get_current_win() then
        local pane_dir = nav[dir]
        vim.system({ wezterm_prog, "cli", "activate-pane-direction", pane_dir }, { text = true }, function(p)
          if p.code ~= 0 then
            vim.notify(
              "Failed to move to pane " .. pane_dir .. "\n" .. p.stderr,
              vim.log.levels.ERROR,
              { title = "Wezterm" }
            )
          end
        end)
      end
    end
  end

  M.set_user_var("IS_NVIM", true)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("_unset_is_nvim_uservar", { clear = true }),
    callback = function(_)
      M.set_user_var("IS_NVIM", false)
    end
  })

  -- Move to window using the movement keys
  for key, dir in pairs(nav) do
    vim.keymap.set("n", "<" .. dir .. ">", navigate(key), { desc = "Go to " .. dir .. " window" })
    vim.keymap.set("n", "<C-" .. key .. ">", navigate(key), { desc = "Go to " .. dir .. " window" })
  end
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("_reset_colorscheme", { clear = true }),
  callback = function(_)
    M.reset_term_colors()
  end
})

return M
