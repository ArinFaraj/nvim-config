
  -- "gc" to comment visual regions/lines
  return {
    'numToStr/Comment.nvim',
    opts = {},
    enabled = not vim.g.vscode,
  }
