return {
  -- Theme inspired by Atom
  'navarasu/onedark.nvim',
  enabled = not vim.g.vscode,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme 'onedark'
    require('onedark').setup({
      style = 'deep',
      transparent = true,
      -- lualine = {
      --   transparent = true
      -- }
    })
    require('onedark').load()
  end,
}
