return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        default_file_explorer = true,
        columns = { 'icon' },
        view_options = {
          show_hidden = true,
        },
        keymaps = {
          ['g?'] = 'actions.show_help',
          ['<CR>'] = 'actions.select',
          ['-'] = 'actions.parent',
          ['_'] = 'actions.open_cwd',
          ['.'] = 'actions.cd',
          ['~'] = { 'actions.cd', opts = { scope = 'tab' } },
          ['gs'] = 'actions.change_sort',
          ['gx'] = 'actions.open_external',
          ['H'] = 'actions.toggle_hidden',
          ['g\\'] = 'actions.toggle_trash',
          ['q'] = 'actions.close',
        },
      }

      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
      vim.keymap.set('n', '\\', '<CMD>Oil<CR>', { desc = 'File explorer (Oil)' })
    end,
  },
}
