vim.api.nvim_set_keymap('n', '<F6>', ":CHADopen<CR>", { noremap = true, silent = true })

local chadtree_settings = {
    ["view.open_direction"] = "right"
}

vim.api.nvim_set_var("chadtree_settings", chadtree_settings)
