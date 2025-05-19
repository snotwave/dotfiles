return {
    {
      'whonore/Coqtail',
      init = function()
          vim.g.loaded_coqtail = 1
          vim.g["coqtail#supported"] = 0
      end,
    },
    {
      'tomtomjhj/vscoq.nvim',
      filetypes = 'coq',
      dependecies = {
        'neovim/nvim-lspconfig',
        'whonore/Coqtail',
      },
      opts = {
            vscoq = {
                completion = {
                    enable = true,
                },
                proof = {
                    mode = "Continuous",
                }
            }
      },
    },
}
