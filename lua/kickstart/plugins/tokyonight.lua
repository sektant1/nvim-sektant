return {
  {
    'RostislavArts/naysayer.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      -- vim.cmd.colorscheme 'naysayer'
    end,
  },
  { 'Mofiqul/dracula.nvim' },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
          keywords = { italic = false }, -- Disable italics in comments
          functions = { italic = false }, -- Disable italics in comments
        },
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.

      vim.api.nvim_set_option_value('background', 'dark', {}) -- or "light"
      vim.cmd [[colorscheme dracula]]
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
