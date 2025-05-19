-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- setup indents
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- assorted settings
vim.wo.number = true
vim.opt.list = true

-- set <Space> as leader 
vim.g.mapleader = "<Space>"

-- Load Package Manager
require("config.lazy")

-- Load Custom Keymaps
require("config/keymap")

-- Load all LSP's in "lua/config/lsp"
local lsp_path = vim.fn.stdpath("config") .. "/lua/config/lsp"

-- Then load all other LSP configs
for _, file in ipairs(vim.fn.readdir(lsp_path)) do
  if file:match("%.lua$") and file ~= "global.lua" then
    local module_name = "config.lsp." .. file:gsub("%.lua$", "")
    require(module_name)
  end
end
