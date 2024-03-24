-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.scrolloff = 15 -- Lines of context
-- vim.g.minipairs_disable = true
if vim.fn.has("win32") > 0 then
  if vim.fn.executable("pwsh") == 1 then
    vim.o.shell = "pwsh"
  elseif vim.fn.executable("powershell") == 1 then
    vim.o.shell = "powershell"
  else
    return LazyVim.error("No powershell executable found")
  end

  -- Setting shell command flags
  vim.o.shellcmdflag =
  "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"

  -- Setting shell redirection
  vim.o.shellredir = '2>&1 | %{ "$_" } | Out-File %s; exit $LastExitCode'

  -- Setting shell pipe
  vim.o.shellpipe = '2>&1 | %{ "$_" } | Tee-Object %s; exit $LastExitCode'

  -- Setting shell quote options
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end

if vim.fn.has("unix") > 0 then
  if vim.fn.executable("zsh") == 1 then
    vim.o.shell = "zsh"
  elseif vim.fn.executable("bash") == 1 then
    vim.o.shell = "bash"
  else
    return LazyVim.error("No powershell executable found")
  end
end
