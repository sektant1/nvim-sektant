return {
  {
    'brenoprata10/nvim-highlight-colors',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      exclude_filetypes = {},
      exclude_buftypes = {},
    },
  },
}
