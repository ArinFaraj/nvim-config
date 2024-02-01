return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- opts.indent = { enable = true, disable = { "dart" } }
    vim.list_extend(opts.ensure_installed, {
      "dart",
      "json",
      "json5",
      "jsonc",
    })
  end,
}
