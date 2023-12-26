-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.shell = vim.fn.has("win32") > 0 and "nu"
  or vim.fn.has("unix") > 0 and "bash"
  or "bash"
vim.opt.scrolloff = 15 -- Lines of context
