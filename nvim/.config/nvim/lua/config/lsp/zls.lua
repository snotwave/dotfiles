vim.lsp.config.zls = {
    cmd = {
        "zls",
    },
    root_markers = {
        "zls.json", "build.zig", ".git"
    },
    filetypes = {
        "zig", "zir"
    }
}
