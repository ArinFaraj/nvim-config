-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "dap-float",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set(
      "n",
      "q",
      "<cmd>close<cr>",
      { buffer = event.buf, silent = true }
    )
  end,
})

-- vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
--   pattern = "*",
--   callback = function()
--     if vim.bo.buftype == "terminal" then
--       vim.cmd("startinsert")
--     end
--   end,
-- })

-- -- OLD WAY OF RUNNING FIX ALL
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.dart",
--   group = vim.api.nvim_create_augroup("LspDartFixAll", {}),
--   callback = function(args)
--     vim.lsp.buf.code_action({
--       context = {
--         only = { "source.fixAll" },
--         diagnostics = {},
--       },
--       apply = true,
--     })
--     vim.cmd("write")
--     -- dart_fix_all(args.buf)
--   end,
-- })

local function lsp_execute_command(val)
  local client = vim.lsp.get_clients({ name = "dartls" })[1]
  if not client then
    print("No dartls client found")
    return
  end
  client.request(
    "workspace/executeCommand",
    { command = val.command.command, arguments = val.command.arguments },
    function(err)
      if err then
        print("Error executing command: " .. vim.inspect(err))
      end
    end
  )
end

local function get_current_line_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = row - 1 })

  return vim.tbl_map(function(diagnostic)
    return {
      code = diagnostic.code,
      message = diagnostic.message,
      severity = diagnostic.severity,
      source = diagnostic.source,
      range = {
        start = {
          character = diagnostic.col,
          line = diagnostic.lnum,
        },
        ["end"] = {
          character = diagnostic.end_col,
          line = diagnostic.end_lnum,
        },
      },
      data = diagnostic.user_data
          and diagnostic.user_data.lsp
          and diagnostic.user_data.lsp.data
        or nil,
      codeDescription = diagnostic.user_data
          and diagnostic.user_data.lsp
          and diagnostic.user_data.lsp.codeDescription
        or nil,
      tags = diagnostic.user_data
          and diagnostic.user_data.lsp
          and diagnostic.user_data.lsp.tags
        or nil,
      relatedInformation = diagnostic.user_data
          and diagnostic.user_data.lsp
          and diagnostic.user_data.lsp.relatedInformation
        or nil,
    }
  end, diagnostics)
end

local function code_action_fix_all()
  local context = { diagnostics = get_current_line_diagnostics() }
  local params = vim.lsp.util.make_range_params()
  params.context = context

  vim.lsp.buf_request(
    0,
    "textDocument/codeAction",
    params,
    function(err, results_lsp)
      if err then
        if err.message then
          vim.notify(err.message, vim.log.levels.ERROR)
        else
          vim.notify(vim.inspect(err), vim.log.levels.ERROR)
        end
        return
      end

      if not results_lsp or vim.tbl_isempty(results_lsp) then
        print("No code actions available")
        return
      end

      for _, result in ipairs(results_lsp) do
        if
          result
          and result.command
          and result.command.command == "dart.edit.fixAll"
        then
          lsp_execute_command(result)
        end
      end
    end
  )
end

local group = vim.api.nvim_create_augroup("LspDartFixAll", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = group,
  pattern = "*.dart",
  callback = function()
    local ok, err = pcall(code_action_fix_all)
    if not ok then
      vim.notify("Fix All error: " .. tostring(err), vim.log.levels.ERROR)
    else
      local format_ok, format_err = pcall(vim.lsp.buf.format)
      if not format_ok then
        vim.notify(
          "Format error: " .. tostring(format_err),
          vim.log.levels.ERROR
        )
      end
    end
  end,
})
