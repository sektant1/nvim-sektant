return {
  {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Gdiffsplit', 'Gvdiffsplit', 'Gedit', 'Gread', 'Gwrite', 'Ggrep', 'GMove', 'GRename', 'GDelete', 'GBrowse' },
    keys = {
      { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
      { '<leader>gb', '<cmd>Git blame<cr>', desc = 'Git blame' },
      { '<leader>gd', '<cmd>Gvdiffsplit<cr>', desc = 'Git diff split' },
      { '<leader>gl', '<cmd>Git log --oneline<cr>', desc = 'Git log' },
      { '<leader>gp', '<cmd>Git push<cr>', desc = 'Git push' },
      { '<leader>gP', '<cmd>Git pull<cr>', desc = 'Git pull' },
    },
  },
  {
    'kdheepak/lazygit.nvim',
    cmd = { 'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },
}
