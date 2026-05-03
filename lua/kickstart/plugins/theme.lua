-- Auto-switch colorscheme to follow active Omarchy OS theme.
-- Reads ~/.config/omarchy/current/theme.name and applies matching colorscheme.
-- Watches that file for changes (omarchy-theme-set rewrites it).
--
-- Theme plugins below mirror ~/.local/share/omarchy/themes/<name>/neovim.lua.

local omarchy_dir = vim.fn.expand '~/.config/omarchy/current'
local theme_name_file = omarchy_dir .. '/theme.name'

-- Map: omarchy theme name → { plugin = lazy plugin name, colorscheme, pre }
local theme_map = {
  ['catppuccin'] = {
    plugin = 'catppuccin',
    colorscheme = 'catppuccin',
    pre = function()
      require('catppuccin').setup { flavour = 'mocha' }
    end,
  },
  ['catppuccin-latte'] = {
    plugin = 'catppuccin',
    colorscheme = 'catppuccin-latte',
    pre = function()
      require('catppuccin').setup { flavour = 'latte' }
    end,
  },
  ['ethereal'] = { plugin = 'ethereal.nvim', colorscheme = 'ethereal' },
  ['everforest'] = {
    plugin = 'everforest-nvim',
    colorscheme = 'everforest',
    pre = function()
      vim.g.everforest_background = 'soft'
    end,
  },
  ['flexoki-light'] = { plugin = 'flexoki', colorscheme = 'flexoki-light' },
  ['gruvbox'] = { plugin = 'gruvbox.nvim', colorscheme = 'gruvbox' },
  ['hackerman'] = { plugin = 'hackerman.nvim', colorscheme = 'hackerman' },
  ['kanagawa'] = { plugin = 'kanagawa.nvim', colorscheme = 'kanagawa' },
  ['lumon'] = { plugin = 'lumon.nvim', colorscheme = 'lumon' },
  ['matte-black'] = { plugin = 'matteblack.nvim', colorscheme = 'matteblack' },
  ['miasma'] = { plugin = 'miasma.nvim', colorscheme = 'miasma' },
  ['nord'] = { plugin = 'nightfox.nvim', colorscheme = 'nordfox' },
  ['osaka-jade'] = { plugin = 'bamboo.nvim', colorscheme = 'bamboo' },
  ['retro-82'] = { plugin = 'retro-82.nvim', colorscheme = 'retro-82' },
  ['ristretto'] = {
    plugin = 'monokai-pro.nvim',
    colorscheme = 'monokai-pro',
    pre = function()
      require('monokai-pro').setup { filter = 'ristretto' }
    end,
  },
  ['rose-pine'] = { plugin = 'rose-pine', colorscheme = 'rose-pine-dawn' },
  ['tokyo-night'] = {
    plugin = 'tokyonight.nvim',
    colorscheme = 'tokyonight-night',
    pre = function()
      require('tokyonight').setup {
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          functions = { italic = false },
        },
      }
    end,
  },
  ['vantablack'] = { plugin = 'vantablack.nvim', colorscheme = 'vantablack' },
  ['white'] = { plugin = 'white.nvim', colorscheme = 'white' },
}

local function read_theme_name()
  local f = io.open(theme_name_file, 'r')
  if not f then
    return nil
  end
  local name = f:read '*l'
  f:close()
  if name then
    name = name:gsub('%s+$', '')
  end
  return name
end

local fallback_theme = 'tokyo-night'

local function apply_theme(name)
  local entry = theme_map[name]
  if not entry then
    if name ~= fallback_theme then
      vim.notify('omarchy-theme: no mapping for "' .. tostring(name) .. '" — falling back to ' .. fallback_theme, vim.log.levels.WARN)
      return apply_theme(fallback_theme)
    end
    return
  end
  if entry.plugin then
    pcall(function()
      require('lazy').load { plugins = { entry.plugin } }
    end)
  end
  if entry.pre then
    pcall(entry.pre)
  end
  local ok, err = pcall(vim.cmd.colorscheme, entry.colorscheme)
  if not ok then
    vim.notify('omarchy-theme: failed to apply ' .. entry.colorscheme .. ': ' .. tostring(err), vim.log.levels.WARN)
    if name ~= fallback_theme then
      apply_theme(fallback_theme)
    end
  end
end

local function apply_omarchy_theme()
  local name = read_theme_name()
  if not name or name == '' then
    name = fallback_theme
  end
  apply_theme(name)
end

-- File watcher — reapply on theme.name change. omarchy-theme-set replaces the
-- file (rename), so the watcher must be restarted after each event.
local function watch_theme()
  local uv = vim.uv or vim.loop
  local handle = uv.new_fs_event()
  if not handle then
    return
  end
  handle:start(theme_name_file, {}, function(err)
    handle:stop()
    handle:close()
    if err then
      return
    end
    vim.schedule(function()
      apply_omarchy_theme()
      vim.defer_fn(watch_theme, 100)
    end)
  end)
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyDone',
  once = true,
  callback = function()
    apply_omarchy_theme()
    watch_theme()
  end,
})

vim.api.nvim_create_user_command('OmarchyThemeReload', apply_omarchy_theme, { desc = 'Re-apply Omarchy theme' })

return {
  -- All Omarchy theme plugins. Active one applied at startup via LazyDone.
  -- Tokyo Night kept lazy=false so a default exists if theme.name is unreadable.
  { 'folke/tokyonight.nvim', lazy = false, priority = 1000 },
  { 'catppuccin/nvim', name = 'catppuccin', lazy = true },
  { 'bjarneo/ethereal.nvim', lazy = true },
  { 'neanias/everforest-nvim', lazy = true },
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
  { 'gthelding/monokai-pro.nvim', lazy = true },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = true },
  { 'bjarneo/vantablack.nvim', lazy = true },
  { 'bjarneo/white.nvim', lazy = true },
}
