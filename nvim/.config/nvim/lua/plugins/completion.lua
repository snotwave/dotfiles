return {
    {

        'neovim/nvim-lspconfig',

    },

    {
        'nvim-treesitter/nvim-treesitter',
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        build = ":TSUpdate",
        opts = {
            highlight = { enable = true },
            indent = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },

    {
      'saghen/blink.cmp',
      -- optional: provides snippets for the snippet source
      dependencies = {
            'rafamadriz/friendly-snippets',
            'onsails/lspkind.nvim'
        },
      -- use a release tag to download pre-built binaries
      version = '1.*',
      -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
      -- build = 'cargo build --release',
      -- If you use nix, you can build from source using latest nightly rust with:
      -- build = 'nix run .#build-plugin',
      opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide", "fallback" },
            ["<CR>"] = { "accept", "fallback" },

            ["<Tab>"] = {
                function(cmp)
                    return cmp.select_next()
                end,
                "snippet_forward",
                "fallback",
            },
            ["<S-Tab>"] = {
                function(cmp)
                    return cmp.select_prev()
                end,
                "snippet_backward",
                "fallback",
            },

            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },
            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },
            ["<C-up>"] = { "scroll_documentation_up", "fallback" },
            ["<C-down>"] = { "scroll_documentation_down", "fallback" },
        },
        appearance = {
          -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          -- Adjusts spacing to ensure icons are aligned
          nerd_font_variant = 'mono',
        },
        -- (Default) Only show the documentation popup when manually triggered
        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 0,
                treesitter_highlighting = true,
            },
            ghost_text = {
                enabled = true,
                show_with_selection = true,
                show_without_selection = true,
            }
        },
        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer', },
          providers = {
              lsp = {
                min_keyword_length = 0,
              },
              path = {
                min_keyword_length = 0,
              },
              snippets = {
                min_keyword_length = 2,
              },
              buffer = {
                  min_keyword_length = 5,
                  max_items = 5,
              }
          }
        },
        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" },
        menu = {
            draw = {
                columns = {
                        { "kind_icon", "label", gap = 4 },
                        { "kind" },
                    },
                    components = {
                        kind_icon = {
                            text = function(item)
                                local kind = require("lspkind").symbol_map[item.kind] or ""
                                return kind .. " "
                            end,
                            highlight = "CmpItemKind",
                        },
                        label = {
                            text = function(item)
                                return item.label
                            end,
                            highlight = "CmpItemAbbr",
                        },
                        kind = {
                            text = function(item)
                                return item.kind
                            end,
                            highlight = "CmpItemKind",
                        },
                }
            }
          },
        },
    },

    {
        'saghen/blink.pairs',
        version = '*', -- (recommended) only required with prebuilt binaries
        dependencies = 'saghen/blink.download',
        opts = {
          mappings = {
            enabled = true,
            pairs = {},
          },
          highlights = {
            enabled = true,
            groups = {
              'BlinkPairsOrange',
              'BlinkPairsPurple',
              'BlinkPairsBlue',
            },
            matchparen = {
              enabled = true,
              group = 'MatchParen',
            },
          },
          debug = false,
        }
    }

    -- {
    --     "hrsh7th/nvim-cmp",
    --     dependencies = {
    -- -        -- source for text in buffer
    --         "hrsh7th/cmp-buffer",
    --         -- source for file system paths
    --         "hrsh7th/cmp-path",
    --         -- source for nvim LSP
    --         "hrsh7th/cmp-nvim-lsp",
    --         {
    --             "L3MON4D3/LuaSnip",
    --             -- follow latest release.
    --             version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    --             -- install jsregexp (optional!).
    --             build = "make install_jsregexp",
    --         },
    --         "saadparwaiz1/cmp_luasnip", -- for autocompletion
    --         "rafamadriz/friendly-snippets", -- useful snippets
    --         "onsails/lspkind.nvim", -- vs-code like pictograms
    --     },
    --     config = function()
    --         local cmp = require("cmp")
    --         local luasnip = require("luasnip")
    --         local lspkind = require("lspkind")
    --         -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    --         require("luasnip.loaders.from_vscode").lazy_load()
    --         cmp.setup({
    --             completion = {
    --                 completeopt = "menu,menuone,preview,noselect",
    --             },
    --             snippet = { -- configure how nvim-cmp interacts with snippet engine
    --                 expand = function(args)
    --                     luasnip.lsp_expand(args.body)
    --                 end,
    --             },
    --             mapping = cmp.mapping.preset.insert({
    --                 ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
    --                 ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
    --                 ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    --                 ["<C-f>"] = cmp.mapping.scroll_docs(4),
    --                 ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
    --                 ["<C-e>"] = cmp.mapping.abort(), -- close completion window
    --                 ["<CR>"] = cmp.mapping.confirm({ select = false }),
    --             }),
    --             -- sources for autocompletion
    --             sources = cmp.config.sources({
    --                 { name = "nvim_lsp"},
    --                 { name = "nvim_lua"},
    --                 { name = "luasnip" }, -- snippets
    --                 { name = "buffer" }, -- text within current buffer
    --                 { name = "path" }, -- file system paths
    --             }),
    --             -- window
    --             window = {
    --             completion = cmp.config.window.bordered({
    --               border = 'single',
    --               col_offset = -1,
    --               scrollbar = false,
    --               scrolloff = 3,
    --               -- Default for bordered() is 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
    --               -- Default for non-bordered, which we'll use here, is:
    --               winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None',
    --             }),
    --             documentation = cmp.config.window.bordered({
    --                  border = 'solid',
    --                  scrollbar = false,
    --                  -- Default for bordered() is 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
    --                  -- Default for non-bordered is 'FloatBorder:NormalFloat'
    --                  -- Suggestion from: https://github.com/hrsh7th/nvim-cmp/issues/2042
    --                  -- is to use 'NormalFloat:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
    --                  -- but this also seems to suffice:
    --                  winhighlight = 'CursorLine:Visual,Search:None',
    --                 }),
    --             },
    --             -- configure lspkind for vs-code like pictograms in completion menu
    --             formatting = {
    --                 format = lspkind.cmp_format({
    --                     maxwidth = 50,
    --                     ellipsis_char = "...",
    --                 }),
    --             },
    --         })
    --     end
    -- }

}
