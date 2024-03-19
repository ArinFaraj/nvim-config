return {
  "iabdelkareem/csharp.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "mfussenegger/nvim-dap",
    "Tastyep/structlog.nvim",
  },
  config = function()
    -- Listen to LSP Attach
    require("mason").setup() -- Mason setup must run before csharp

    local mason_omnisharp_path = vim.fn.stdpath("data")
        .. "/mason/packages/omnisharp/"
    local omnisharp_cmd = mason_omnisharp_path
        .. "omnisharp"
        .. (vim.fn.has("win32") == 1 and ".cmd" or "")

    require("csharp").setup({
      lsp = {
        cmd_path = omnisharp_cmd,
      },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = args.buf,
          callback = function()
            -- Format the code before you run fix usings
            vim.lsp.buf.format({ timeout = 1000, async = false })

            -- If the file is C# then run fix usings
            if vim.bo[0].filetype == "cs" then
              require("csharp").fix_usings()
            end
          end,
        })
      end,
    })
  end,
}
