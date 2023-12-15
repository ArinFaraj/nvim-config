return {
  'akinsho/flutter-tools.nvim',
  enabled = not vim.g.vscode,
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim',   -- optional for vim.ui.select
  },
  config = true,
}
