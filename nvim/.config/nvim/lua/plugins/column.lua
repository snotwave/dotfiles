local conf = {
    -- Dynamically adjusts the colorcolumn behavior based on editing
    -- mode:
    -- 1. In insert/replace/selection mode: update the color gradually
    --    based on current line length
    -- 2. In other modes: update the color based on longest visible line,
    --    if there's any line that exceeds the colorcolumn limit, show
    --    the colorcolumn with warning color, else conceal the
    --    colorcolumn entirely
    scope = function()
      if vim.fn.mode():find('^[iRss\x13]') ~= nil then
        return vim.fn.strdisplaywidth(vim.fn.getline('.'))
      end

      -- Don't show in read-only buffers
      if not vim.bo.ma or vim.bo.ro then
        return 0
      end

      -- Find maximum length within visible range
      local max_len = math.max(
        unpack(
          vim.tbl_map(
            vim.fn.strdisplaywidth,
            vim.api.nvim_buf_get_lines(
              0,
              vim.fn.line('w0') - 1,
              vim.fn.line('w$'),
              false
            )
          )
        )
      )

      if max_len >= cc_resolve(vim.wo.cc) then
        return max_len
      end
      return 0
    end,
}

return {
    'Bekaboo/deadcolumn.nvim',
    config = function()
        require('deadcolumn').setup(conf)
        vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
            command = "setlocal colorcolumn=80"
        })
    end,
}
