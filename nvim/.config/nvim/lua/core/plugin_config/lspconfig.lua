local lspconfig = require "lspconfig"
local util = require("lspconfig/util")
local configs = require("lspconfig/configs")

-- allows for linebreaks in diagnostics
vim.diagnostic.config({
    virtual_text = false
})

-- individual server setup

-- python
lspconfig.pyright.setup{}

-- haskell
require('lspconfig')['hls'].setup{
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
}

-- ocaml
lspconfig.ocamllsp.setup{
    filetypes = { "ocaml", "menhir", "ocamlinterface", "ocamllex", "reason", "dune", 'ml' },
}

-- racket
lspconfig.racket_langserver.setup{}

-- zig
lspconfig.zls.setup{}

-- clang
lspconfig.clangd.setup{}

-- rust
lspconfig.rust_analyzer.setup{}

-- prolog
lspconfig.prolog_ls.setup{}
configs.prolog_lsp = {
  default_config = {
    cmd = {"swipl",
           "-g", "use_module(library(lsp_server)).",
           "-g", "lsp_server:main",
           "-t", "halt",
           "--", "stdio"};
    filetypes = {"prolog"};
    root_dir = util.root_pattern("pack.pl");
  };
  docs = {
     description = [[
  https://github.com/jamesnvc/prolog_lsp

  Prolog Language Server
  ]];
  }
}

