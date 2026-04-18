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

function leave_snippet()
  if
    ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
    and require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()]
    and not require('luasnip').session.jump_active
  then
    require('luasnip').unlink_current()
  end
end

-- stop snippets when you leave to normal mode
vim.api.nvim_command [[
    autocmd ModeChanged * lua leave_snippet()
]]
