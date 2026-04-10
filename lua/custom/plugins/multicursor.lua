return {
  {
    'jake-stewart/multicursor.nvim',
    branch = '1.0',
    config = function()
      local mc = require 'multicursor-nvim'
      mc.setup()

      local set = vim.keymap.set

      -- Add or skip cursor above/below
      set({ 'n', 'x' }, '<up>', function() mc.lineAddCursor(-1) end)
      set({ 'n', 'x' }, '<down>', function() mc.lineAddCursor(1) end)
      set({ 'n', 'x' }, '<leader><up>', function() mc.lineSkipCursor(-1) end)
      set({ 'n', 'x' }, '<leader><down>', function() mc.lineSkipCursor(1) end)

      -- Match word/selection: add next/prev, skip next/prev
      set({ 'n', 'x' }, '<C-n>', function() mc.matchAddCursor(1) end)
      set({ 'n', 'x' }, '<C-p>', function() mc.matchSkipCursor(1) end)

      -- Add/remove cursors with ctrl+click
      set('n', '<c-leftmouse>', mc.handleMouse)
      set('n', '<c-leftdrag>', mc.handleMouseDrag)
      set('n', '<c-leftrelease>', mc.handleMouseRelease)

      -- Toggle cursor
      set({ 'n', 'x' }, '<c-q>', mc.toggleCursor)

      -- Keymap layer: only active when multiple cursors exist
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

      -- Highlights
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
