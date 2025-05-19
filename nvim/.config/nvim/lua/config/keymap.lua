
vim.keymap.set('n', '<F6>', ':Oil<CR>', {silent = true})
vim.keymap.set('n', '<F7>', ':Trouble diagnostics toggle<CR>', {silent = true})

-- <ESC> exits terminal mode
vim.keymap.set('t', '<Esc>', "<C-\\><C-n><C-w>h",{silent = true})
