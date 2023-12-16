return {
  'nvim-tree/nvim-tree.lua',
  enabled = not vim.g.vscode,
  config = true,
  opts = {
    sort_by = "case_sensitive",
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = true,
    },
  }
}
