return {
  {
    'sektant1/executioner.nvim',
    cmd = { 'Executioner', 'ExecutionerRerun', 'ExecutionerConfigure', 'ExecutionerBuild', 'ExecutionerBuildLast', 'CreateProject' },
    keys = {
      {
        '<F5>',
        function()
          require('executioner').run_scripts()
        end,
        desc = 'Executioner: run script',
      },
      {
        '<F6>',
        function()
          require('executioner').rerun()
        end,
        desc = 'Executioner: rerun last script',
      },
      {
        '<F7>',
        function()
          require('executioner').configure()
        end,
        desc = 'Executioner: configure project',
      },
      {
        '<F4>',
        function()
          require('executioner').build()
        end,
        desc = 'Executioner: build target',
      },
      {
        '<F3>',
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
