local transparent_groups = {
  'Normal',
  'NormalNC',
  'NormalFloat',
  'FloatBorder',
  'SignColumn',
  'StatusLine',
  'StatusLineNC',
  'TabLine',
  'TabLineFill',
  'WinSeparator',
}

local function clear_backgrounds()
  for _, group in ipairs(transparent_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok then
      hl.bg = nil
      hl.ctermbg = nil
      vim.api.nvim_set_hl(0, group, hl)
    end
  end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = clear_backgrounds,
})

return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      style = 'night',
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        functions = { italic = false },
      },
    },
    config = function(_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme 'tokyonight-night'
      clear_backgrounds()
    end,
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = true,
    opts = { flavour = 'mocha' },
  },
  { 'bjarneo/ethereal.nvim', lazy = true },
  {
    'neanias/everforest-nvim',
    lazy = true,
    config = function()
      vim.g.everforest_background = 'soft'
    end,
  },
  { 'kepano/flexoki-neovim', name = 'flexoki', lazy = true },
  { 'ellisonleao/gruvbox.nvim', lazy = true },
  { 'bjarneo/aether.nvim', lazy = true },
  { 'bjarneo/hackerman.nvim', dependencies = { 'bjarneo/aether.nvim' }, lazy = true },
  { 'rebelot/kanagawa.nvim', lazy = true },
  { 'omacom-io/lumon.nvim', lazy = true },
  { 'tahayvr/matteblack.nvim', lazy = true },
  { 'OldJobobo/miasma.nvim', lazy = true },
  { 'EdenEast/nightfox.nvim', lazy = true },
  { 'ribru17/bamboo.nvim', lazy = true },
  { 'OldJobobo/retro-82.nvim', lazy = true },
  {
    'gthelding/monokai-pro.nvim',
    lazy = true,
    opts = { filter = 'ristretto' },
  },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = true },
  { 'bjarneo/vantablack.nvim', lazy = true },
  { 'bjarneo/white.nvim', lazy = true },
}
