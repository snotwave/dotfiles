vim.keymap.set('n', '<LocalLeader>T', ':belowright split | resize 10 |  terminal<CR> ') -- spawns a terminal
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]]) -- ESC exits terminal mode
vim.keymap.set('n', '<LocalLeader>l', ':bnext<CR>') -- next buffer
vim.keymap.set('n', '<LocalLeader>h', ':bprevious<CR>') -- previous buffer
