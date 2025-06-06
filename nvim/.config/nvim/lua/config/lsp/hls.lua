vim.lsp.config.hls = {
  cmd = {
    'haskell-language-server-wrapper',
    '--lsp'
    },
    root_markers = {
        'hie.yaml', 'stack.yaml','cabal.project', '*.cabal', 'package.yaml'
    },
    filetypes = { 'haskell', 'lhaskell', 'cabal' },
}
