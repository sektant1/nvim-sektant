return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 300,
      icons = {
        mappings = false,
        keys = {},
      },
      win = {
        no_overlap = true,
        padding = { 1, 1 },
        title = false,
      },
      layout = {
        width = { min = 20 },
        spacing = 2,
      },
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= 'which_key_ignore'
      end,
      spec = {
        { '<leader>b', group = 'Debug' },
        { '<leader>s', group = 'Search' },
        { '<leader>c', group = 'CMake' },
        { '<leader>l', group = 'LSP' },
        { '<leader>t', group = 'Toggles' },
        { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
        { '<leader>p', group = 'Profile' },
        { '<leader>m', group = 'Harpoon' },
        { '<leader>j', group = 'Test' },
        { '<leader>H', group = 'HTTP' },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
