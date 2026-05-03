-- Navigation stack: yazi (browse) + harpoon (pin) + telescope (search)
-- + flash (in-buffer jump) + aerial (symbol outline) + grug-far (find/replace)
-- All keymaps live in lua/keymaps.lua.

return {
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      modes = {
        search = { enabled = false },
        char = { enabled = true, jump_labels = true },
      },
    },
  },

  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    cmd = { 'AerialToggle', 'AerialNavToggle', 'AerialNext', 'AerialPrev' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      backends = { 'lsp', 'treesitter', 'markdown', 'man' },
      layout = {
        max_width = { 50, 0.3 },
        min_width = 30,
        default_direction = 'right',
      },
      filter_kind = {
        c = { 'Function', 'Struct', 'Enum', 'Class', 'Constructor', 'Interface', 'Module', 'Method' },
        cpp = { 'Function', 'Struct', 'Enum', 'Class', 'Constructor', 'Interface', 'Module', 'Method', 'Namespace' },
        typescript = { 'Function', 'Class', 'Interface', 'Method', 'Constructor', 'Module' },
        typescriptreact = { 'Function', 'Class', 'Interface', 'Method', 'Constructor', 'Module', 'Variable' },
        javascript = { 'Function', 'Class', 'Method', 'Constructor', 'Module' },
        javascriptreact = { 'Function', 'Class', 'Method', 'Constructor', 'Module', 'Variable' },
      },
      show_guides = true,
      autojump = true,
      close_on_select = true,
    },
  },

  {
    'MagicDuck/grug-far.nvim',
    cmd = { 'GrugFar' },
    opts = { headerMaxWidth = 80 },
  },
}
