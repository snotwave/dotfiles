-- packer bootstrap to make these dotfiles portable 

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- My plugins here

  -- tree
  use 'ms-jpq/chadtree'
  use 'nvim-telescope/telescope.nvim'

  -- code completion
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'williamboman/nvim-lsp-installer'
  use 'jmbuhr/otter.nvim'
  use({
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
    end,
  })

  -- treesitter + parsers
  use 'nvim-treesitter/nvim-treesitter'
  use 'MDeiml/tree-sitter-markdown'

  -- image support
  use '3rd/image.nvim'
  use 'vhyrro/hologram.nvim'

  -- status bar
  use {'nvim-lualine/lualine.nvim', 
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }}

  -- splash screen
  use {
    'goolord/alpha-nvim',
    config = function ()
        require'alpha'.setup(require'alpha.themes.dashboard'.config)
    end
  }

  -- cursor underline/highlighting
  use 'yamatsum/nvim-cursorline'

  -- git integration
  use 'tpope/vim-fugitive'

  -- language specific
  -- python
  use 'benlubas/molten-nvim' -- ipynb support
  -- agda
  use 'kana/vim-textobj-user'
  use 'neovimhaskell/nvim-hs.vim'
  use 'Arkissa/cmp-agda-symbols' -- unicode symbol support for agda

  -- misc
  use 'machakann/vim-highlightedyank'
  use 'nvim-lua/plenary.nvim'
  use 'windwp/nvim-autopairs'
  use 'bling/vim-bufferline'
  use 'petertriho/nvim-scrollbar'
  use 'pocco81/auto-save.nvim'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
