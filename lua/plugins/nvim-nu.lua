return {
  "LhKipp/nvim-nu",
  enabled = not vim.g.vscode,
  opts = {
    use_lsp_features = false,
  },
  build = ":TSInstall nu",
}
