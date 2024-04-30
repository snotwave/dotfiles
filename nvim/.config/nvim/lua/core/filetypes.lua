-- vertical splits for all help files
vim.api.nvim_create_autocmd(
    'FileType', 
    {
	    pattern = 'help',
	    callback = function()
		    vim.cmd("wincmd L")
	    end
    }
)

-- ipynb support, integration with Molten
-- requires quitting/reloading the buffer or else you'll get md errors
vim.api.nvim_create_autocmd(
    {
        "BufNewFile",
        "BufRead",
    },
    {
        pattern = {"*.ipynb"},
        callback = function()
            vim.cmd("MoltenInit python3")
            vim.cmd('set filetype=markdown')
            require'otter'.activate({'python', 'r', 'lua'})
        end
    }
)

-- agda support, integration with cornelis
vim.api.nvim_create_autocmd(
    {
        "BufRead",
        "BufNewFile",
        "BufWritePost",
    },
    {
        pattern = {"*.agda"},
        callback = function()
            vim.cmd("CornelisLoad")
        end
    }
)

vim.api.nvim_create_autocmd(
    {
        "QuitPre"
    },
    {
        pattern = {"*.agda"},
        callback = function()
            vim.cmd("CornelisCloseInfoWindows")
        end
    }
)

vim.api.nvim_create_autocmd(
    {
        "FileType"
    },
    {
        pattern = {"*.agda"},
        callback = function()
            vim.lsp.start({
            cmd = { "als" },
            root_dir = vim.fn.getcwd(), -- Use PWD as project root dir.
            })
        end
    }
)
-- .ml automatically sets to OCaml
vim.api.nvim_create_autocmd(
    'FileType',
    {
        pattern = "*.ml",
        callback = function()
            vim.cmd('set filetype=ml')
        end
    }
)
