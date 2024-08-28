local configs = require 'nvim-treesitter.configs'

local parsers = require 'nvim-treesitter.parsers'
local parser_config = parsers.get_parser_configs()

configs.setup {
    -- autoinstall missing parsers when entering buffer
    auto_install = true,

    highlight = {
        enable = true,
    }
}
