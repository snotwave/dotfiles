-- notifications
return {
    "rcarriga/nvim-notify",
    config = function()
        require("notify").setup {
            style = "wrapped-compact",
            stages = "static",
            top_down = false,
        }
    end,
}
