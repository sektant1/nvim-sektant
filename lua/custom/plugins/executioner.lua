return {
  {
    'sektant1/executioner.nvim',
    cmd = { 'Executioner', 'ExecutionerRerun' },
    keys = {
      {
        '<leader>er',
        function()
          require('executioner').run_scripts()
        end,
        desc = 'Executioner: run script',
      },
    },
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    opts = {},
    config = function(_, opts)
      require('executioner').setup(opts)
      require('telescope').load_extension 'executioner'
    end,
  },
}
