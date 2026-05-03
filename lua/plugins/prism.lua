-- Prism.nvim - Claude Code integration
return {
  dir = vim.fn.expand("~/.local/share/prism.nvim"),
  lazy = false,
  config = function()
    require("prism.core").setup({
      toggle_key = "<C-;>",
      terminal_width = 0.4,
      auto_reload = true,
      mcp = true,
      passthrough = true,
    })
  end,
}
