return {
  {
    'sektant1/executioner.nvim',
    cmd = { 'Executioner', 'ExecutionerRerun', 'ExecutionerConfigure', 'ExecutionerBuild', 'ExecutionerBuildLast', 'CreateProject' },
    keys = {
      {
        '<leader>er',
        function()
          require('executioner').run_scripts()
        end,
        desc = 'Executioner: run script',
      },
      {
        '<leader>eR',
        function()
          require('executioner').rerun()
        end,
        desc = 'Executioner: rerun last script',
      },
      {
        '<leader>ec',
        function()
          require('executioner').configure()
        end,
        desc = 'Executioner: configure project',
      },
      {
        '<leader>eb',
        function()
          require('executioner').build()
        end,
        desc = 'Executioner: build target',
      },
      {
        '<leader>eB',
        function()
          require('executioner').build_last()
        end,
        desc = 'Executioner: rerun last build',
      },
      {
        '<leader>ep',
        function()
          require('executioner').create_project()
        end,
        desc = 'Executioner: create project',
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
