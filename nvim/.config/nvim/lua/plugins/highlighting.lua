-- this is where all highlighting-related plugins will go

return {

    {

        "RRethy/vim-illuminate",

    },

    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = false },
        dashboard = { 
            sections = {
              { section = "header" },
              { section = "keys", gap = 1, padding = 1 },
              { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
              { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
              {
                pane = 2,
                icon = " ",
                title = "Git Status",
                section = "terminal",
                enabled = function()
                  return Snacks.git.get_root() ~= nil
                end,
                cmd = "git status --short --branch --renames",
                height = 5,
                padding = 1,
                ttl = 5 * 60,
                indent = 3,
              },
              { section = "startup" },
            },
        },
        explorer = { enabled = false },
        indent = { enabled = false },
        input = { enabled = false },
        picker = { enabled = false },
        notifier = { enabled = false },
        quickfile = { enabled = false },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false },
      },
    }
}
