return {
  {
    'codevogel/hatch.nvim',
    event = 'BufNewFile',
    cmd = { 'Hatch', 'HatchForce', 'HatchCloneTemplates' },
    opts = {
      create_autocmd = true,
    },
  },
}
