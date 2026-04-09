vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end
  end,
})

-- Reload buffer on FocusGained, TermLeave, BufEnter, WinEnter, CursorHold
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermLeave', 'BufEnter', 'WinEnter', 'CursorHold' }, {
  callback = function()
    if vim.fn.mode() ~= 'c' then -- Don't check while in command line
      vim.cmd 'checktime'
    end
  end,
})
