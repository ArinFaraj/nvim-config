if not vim.g.vscode then
  return {}
end

local enabled = {
  "flit.nvim",
  "lazy.nvim",
  "leap.nvim",
  "mini.ai",
  -- "mini.comment",
  "mini.pairs",
  "mini.surround",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "nvim-ts-context-commentstring",
  "vim-repeat",
  "LazyVim",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  ---@diagnostic disable-next-line: undefined-field
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimKeymaps",
  callback = function()
    vim.keymap.set("n", "<leader><space>", "<cmd>Find<cr>")
    vim.keymap.set(
      "n",
      "<leader>/",
      [[<cmd>call VSCodeNotify('workbench.action.findInFiles')<cr>]]
    )
    vim.keymap.set(
      "n",
      "<leader>ss",
      [[<cmd>call VSCodeNotify('workbench.action.gotoSymbol')<cr>]]
    )
    vim.keymap.set("x", "gc", "<Plug>VSCodeCommentary", {})
    vim.keymap.set("n", "gc", "<Plug>VSCodeCommentary", {})
    vim.keymap.set("o", "gc", "<Plug>VSCodeCommentary", {})
    vim.keymap.set("n", "gcc", "<Plug>VSCodeCommentaryLine", {})
    vim.keymap.set(
      "n",
      "<leader>ca",
      [[<cmd>call VSCodeNotify('editor.action.quickFix')<cr>]]
    )
    vim.keymap.set(
      "n",
      "<leader>bd",
      [[<cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<cr>]]
    )
    -- Got to next tab with shift+l and previous with shift+h
    vim.keymap.set(
      "n",
      "<S-l>",
      [[<cmd>call VSCodeNotify('workbench.action.nextEditor')<cr>]]
    )
    vim.keymap.set(
      "n",
      "<S-h>",
      [[<cmd>call VSCodeNotify('workbench.action.previousEditor')<cr>]]
    )
    vim.keymap.set(
      "n",
      "C-j",
      "<Cmd>call VSCodeNotify('workbench.action.navigateDown')<CR>"
    )
    vim.keymap.set(
      "x",
      "C-j",
      "<Cmd>call VSCodeNotify('workbench.action.navigateDown')<CR>"
    )
    vim.keymap.set(
      "n",
      "C-k",
      "<Cmd>call VSCodeNotify('workbench.action.navigateUp')<CR>"
    )
    vim.keymap.set(
      "x",
      "C-k",
      "<Cmd>call VSCodeNotify('workbench.action.navigateUp')<CR>"
    )
    vim.keymap.set(
      "n",
      "C-h",
      "<Cmd>call VSCodeNotify('workbench.action.navigateLeft')<CR>"
    )
    vim.keymap.set(
      "x",
      "C-h",
      "<Cmd>call VSCodeNotify('workbench.action.navigateLeft')<CR>"
    )
    vim.keymap.set(
      "n",
      "C-l",
      "<Cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>"
    )
    vim.keymap.set(
      "x",
      "C-l",
      "<Cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>"
    )
  end,
})

return {
  {
    "LazyVim/LazyVim",
    config = function(_, opts)
      opts = opts or {}
      -- disable the colorscheme
      opts.colorscheme = function() end
      require("lazyvim").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = false } },
  },
}
