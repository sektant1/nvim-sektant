-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    lazy = false,
    keys = {
      { '<C-n>', ':Neotree toggle<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = false,
        },
        window = {
          width = 30,
          mappings = {
            ['<C-n>'] = 'close_window',
            ['Y'] = {
              function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                vim.fn.setreg('+', path)
                vim.notify('Copied: ' .. path)
              end,
              desc = 'Copy Path to Clipboard',
            },
          },
        },
      },
    },
  },
  {
    'adelarsq/image_preview.nvim',
    event = 'VeryLazy',
    config = function()
      require('image_preview').setup()
    end,
  },
}
