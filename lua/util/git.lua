---@class util.git
local M = {}

local Job = require("plenary.job")

function M.get_session_name()
  local git_root_dirs = vim.fn.systemlist("git rev-parse --show-toplevel")
  if vim.v.shell_error == 0 then
    local git_root_path = git_root_dirs[1]
    local git_basename = vim.fs.basename(git_root_path)
    local git_branch_name = string.gsub(vim.fn.system("git rev-parse --abbrev-ref HEAD"), "%s*$", "")
    local session_name = git_basename .. "-" .. string.gsub(git_branch_name, "/", "-")
    return session_name
  end
  return nil
end

local function git_branch_session_exists(name)
  for _, session in pairs(require("mini.sessions").detected) do
    if session.name == name then
      return true
    end
  end
  return false
end

function M.get_git_branch_session()
  local session_name = M.get_session_name()
  if session_name ~= nil then
    if git_branch_session_exists(session_name) then
      return session_name
    end
  end
  return nil
end

function M.set_git_session_global()
  local data = {}
  Job:new({
    command = "git",
    args = { "rev-parse", "--show-toplevel", "--abbrev-ref", "HEAD" },
    on_stdout = function(_, line)
      table.insert(data, line)
    end,
    on_exit = function(code)
      if code.code == 0 then
        local git_root_path = data[1]
        local git_basename = string.match(git_root_path, "[^/]*$")
        local git_branch_name = string.gsub(data[2], "%s*$", "")
        local session_name = git_basename .. "-" .. string.gsub(git_branch_name, "/", "-")
        local session_exists = git_branch_session_exists(session_name)
        if session_exists then
          vim.g.git_session_name = session_name
          return
        end
      end
      vim.g.git_session_name = ""
    end,
  }):start()
end

--- Open picker for branch/commit and run vim function `fn` with picked value as argument
---@param fn string
---@param mode string?
function M.run_openingh_with_picked_ref(fn, mode)
  local branches = vim.fn.systemlist("git rev-parse --abbrev-ref origin/HEAD HEAD")
  local default = vim.fs.basename(branches[1])
  local current = string.gsub(branches[2], "%s*$", "")
  local commit = vim.fn.system("git log -n 1 --pretty=format:'%H'")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", false)
  vim.ui.select({
    { text = string.format("Current branch [%s]", current), value = current },
    { text = string.format("Default branch [%s]", default), value = default },
    { text = string.format("Last commit [%s]", commit), value = commit },
  }, {
    prompt = "Which branch to use?",
    format_item = function(item)
      return item.text
    end,
  }, function(choice)
    if choice ~= nil then
      if mode == "v" then
        vim.cmd(vim.api.nvim_replace_termcodes(string.format("normal gv:%s %s<CR>", fn, choice.value), true, true, true))
      else
        vim.cmd(string.format("%s %s", fn, choice.value))
      end
    end
  end)
end

return M
