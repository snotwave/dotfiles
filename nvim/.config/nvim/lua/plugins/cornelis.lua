return {
    {
        'isovector/cornelis',
        name = 'cornelis',
        ft = 'agda',
        build = 'stack install',
        dependencies = {
            'neovimhaskell/nvim-hs.vim',
            'kana/vim-textobj-user',
            'liuchengxu/vim-which-key'
        },
        version = '*',
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
            	pattern = "agda",
            	callback = function()
            		vim.opt_local.shiftwidth = 2
            		vim.opt_local.tabstop = 2
            	end
            })
            vim.cmd [[ 
                au BufRead,BufNewFile *.agda call AgdaFiletype()
                
                function! AgdaFiletype()
                    inoremap <localleader><F8>:call cornelis#prompt_input()<CR>
                    nnoremap <buffer> <leader>l     :CornelisLoad<CR> :CornelisQuestionToMeta<CR>
                    nnoremap <buffer> <leader>r     :CornelisRefine<CR>
                    nnoremap <buffer> <leader>d     :CornelisMakeCase<CR>
                    nnoremap <buffer> <leader>,     :CornelisTypeContext<CR>
                    nnoremap <buffer> <leader>.     :CornelisTypeContextInfer<CR>
                    nnoremap <buffer> <leader>n     :CornelisSolve<CR>
                    nnoremap <buffer> <leader>a     :CornelisAuto<CR>
                    nnoremap <buffer> gd            :CornelisGoToDefinition<CR>
                    nnoremap <buffer> [/            :CornelisPrevGoal<CR>
                    nnoremap <buffer> ]/            :CornelisNextGoal<CR>
                    nnoremap <buffer> <C-A>         :CornelisInc<CR>
                    nnoremap <buffer> <C-X>         :CornelisDec<CR>
                    nnoremap <buffer> <C-space>     :CornelisGive<CR>
                endfunction

                au BufWritePost *.agda execute "normal! :CornelisLoad\<CR>"
                
                function! CornelisLoadWrapper()
                 if exists(":CornelisLoad") ==# 2
                   CornelisLoad
                 endif
               endfunction
               au BufReadPre *.agda call CornelisLoadWrapper()
               au BufReadPre *.lagda* call CornelisLoadWrapper()           
            ]]
            vim.g.cornelis_split_location = "right"
            vim.g.cornelis_max_width = 50
        end
    },
}
