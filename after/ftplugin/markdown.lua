vim.opt_local.spell = false

if vim.lsp.document_color and vim.lsp.document_color.enable then
  pcall(vim.lsp.document_color.enable, false, { bufnr = 0 })
end
