return {
  {
    'sektant1/executioner.nvim',
    cmd = { 'Executioner', 'ExecutionerRerun', 'ExecutionerConfigure', 'ExecutionerBuild', 'ExecutionerBuildLast', 'CreateProject' },
    event = 'VeryLazy',
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
