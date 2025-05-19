-- molten keybindings
vim.api.nvim_set_keymap('n', '<LocalLeader>r', ':MoltenEvaluateOperator<CR>' , {noremap = ture, silent = true});
vim.api.nvim_set_keymap('x', '<LocalLeader>r', ':<C-u>MoltenEvaluateVisual<CR>' , {noremap = ture, silent = true});
vim.api.nvim_set_keymap('n', '<LocalLeader>rr', ':MoltenEvaluateLine<CR>' , {noremap = ture, silent = true});
vim.api.nvim_set_keymap('n', '<LocalLeader>rc', ':MoltenReevaluateCell<CR>' , {noremap = ture, silent = true});
vim.api.nvim_set_keymap('n', '<LocalLeader>rd', ':MoltenDelete<CR>' , {noremap = ture, silent = true});
vim.api.nvim_set_keymap('n', '<LocalLeader>ro', ':MoltenShowOutput<CR>' , {noremap = ture, silent = true});
vim.api.nvim_set_keymap('n', '<LocalLeader>rp', ':MoltenImagePopup<CR>', {noremap=true, silent=true});

-- molten options
vim.g.molten_image_provider = 'image.nvim'
