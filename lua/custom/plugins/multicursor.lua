return {
  {
    'jake-stewart/multicursor.nvim',
    branch = '1.0',
    event = 'VeryLazy',
    config = function()
      local mc = require 'multicursor-nvim'
      mc.setup()

      -- Layer keymaps (only active while multiple cursors exist) must stay
      -- here because mc.addKeymapLayer is plugin-specific.
      mc.addKeymapLayer(function(layerSet)
        layerSet({ 'n', 'x' }, '<left>', mc.prevCursor)
        layerSet({ 'n', 'x' }, '<right>', mc.nextCursor)
        layerSet({ 'n', 'x' }, '<leader>x', mc.deleteCursor)
        layerSet('n', '<esc>', function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      local hl = vim.api.nvim_set_hl
      hl(0, 'MultiCursorCursor', { reverse = true })
      hl(0, 'MultiCursorVisual', { link = 'Visual' })
      hl(0, 'MultiCursorSign', { link = 'SignColumn' })
      hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
      hl(0, 'MultiCursorDisabledCursor', { reverse = true })
      hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
    end,
  },
}
