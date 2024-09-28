local signs = {
  { name = "DiagnosticSignError", text = "" },
  { name = "DiagnosticSignWarn", text = "" },
  { name = "DiagnosticSignHint", text = "" },
  { name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

local config = {
  -- disable virtual text
  virtual_text = false,
  -- show signs
  signs = {
    active = signs,
  },
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
}

vim.diagnostic.config(config)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
})

local snip_status_ok, luasnip = pcall(require, "luasnip")
if snip_status_ok then
  require("luasnip/loaders/from_vscode").lazy_load()
end

local lsp_config_ok, lspconfig = pcall(require, "lspconfig")
if not lsp_config_ok then
  return
end

local vue_language_server_path = require("mason-registry").get_package("vue-language-server"):get_install_path()
  .. "/node_modules/@vue/language-server"

local servers = {
  bashls = true,
  fsautocomplete = true,
  hls = {
    manual_install = true
  },
  jsonls = true,
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
      },
    },
    on_init = function(client)
      local path = client.workspace_folders[1].name
      if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
        client.config.settings = vim.tbl_deep_extend("force", client.config.settings.Lua, {
          runtime = {
            version = "LuaJIT",
          },
          workspace = {
            library = { vim.env.VIMRUNTIME },
          },
        })
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      end
      return true
    end,
  },
  pyright = true,
  texlab = true,
  ts_ls = {
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = vue_language_server_path,
          languages = { "vue" },
        },
      },
    },
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = function(client, bufnr)
      if vim.api.nvim_get_option_value("filetype", { buf = bufnr }) ~= "vue" then
        require("nvim-navic").attach(client, bufnr)
      end
    end,
  },
  vimls = true,
  volar = true,
  yamlls = true,
}

-- From https://github.com/tjdevries/config.nvim/blob/37c9356fd40a8d3589638c8d16a6a6b1274c40ca/lua/custom/plugins/lsp.lua
local servers_to_install = vim.tbl_filter(function(key)
  local t = servers[key]
  if type(t) == "table" then
    return not t.manual_install
  else
    return t
  end
end, vim.tbl_keys(servers))

require("mason-tool-installer").setup({ ensure_installed = servers_to_install })

local capabilities = require("cmp_nvim_lsp").default_capabilities()

for name, config in pairs(servers) do
  if config == true then
    config = {}
  end
  config = vim.tbl_deep_extend("force", {}, {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      require("nvim-navic").attach(client, bufnr)
    end,
  }, config)

  lspconfig[name].setup(config)
end
