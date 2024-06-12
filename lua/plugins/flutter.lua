return {
  -- {
  --   "neovim/nvim-lspconfig",
  --   ft = { "dart" },
  --   opts = {
  --     setup = {
  --       -- stylua: ignore
  --       dartls = function() return true end,
  --     },
  --   },
  -- },
  {
    "m00qek/baleia.nvim",
    config = function()
      vim.g.baleia =
        require("baleia").setup({ log = "INFO", line_starts_at = 6 })
      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "__FLUTTER_DEV_LOG__",
        callback = function()
          vim.o.modifiable = true
          vim.g.baleia.automatically(vim.api.nvim_get_current_buf())
          vim.o.modifiable = false
        end,
      })
      vim.api.nvim_create_user_command(
        "BaleiaLogs",
        vim.g.baleia.logger.show,
        { bang = true }
      )
    end,
  },
  {
    "ArinFaraj/flutter-tools.nvim",
    ft = "dart",
    enabled = not vim.o.diff,
    dependencies = {
      "Nash0x7E2/awesome-flutter-snippets",
    },
    config = function()
      local register_keys = function()
        local wk = require("which-key")

        wk.register({
          d = { "<cmd>FlutterDevices<cr>", "Flutter Devices (Run)" },
          o = { "<cmd>FlutterOutlineToggle<cr>", "Flutter Outline" },
          q = { "<cmd>FlutterQuit<cr>", "Flutter Quit" },
          r = { "<cmd>FlutterRestart<cr>", "Flutter Restart" },
          p = { "<cmd>FlutterPubGet<cr>", "Flutter Pub Get" },
          P = { "<cmd>FlutterPubUpgrade<cr>", "Flutter Pub Upgrade" },
          l = { "<cmd>FlutterLogClear<cr>", "Flutter Log Clear" },
          e = { "<cmd>FlutterEmulators<cr>", "Emulators" },
          x = { "<cmd>FlutterOpenDevTools<cr>", "Open DevTools" },
          c = { "<cmd>FlutterCopyProfilerUrl<cr>", "Copy Profiler Url" },
        }, {
          prefix = "<leader>m",
          name = "+dart",
        })
      end

      register_keys()
      require("flutter-tools").setup({
        ui = {
          -- border = "single",
          notification_style = "plugin",
        },
        decoration = {
          statusline = {
            app_version = true,
          },
        },
        widget_guides = {
          enabled = true,
        },
        closing_tags = {
          enabled = true,
          prefix = "  ",
        },
        outline = {
          open_cmd = "botright 40vnew",
          auto_open = false,
        },
        dev_log = {
          enabled = true,
          notify_errors = true,
          open_cmd = "botright 5sp",
        },
        dev_tools = {
          auto_open_browser = true,
        },
        lsp = {
          on_attach = function()
            -- local dart_fix_all = function(bufnr, isPreflight)
            --   local command = "edit.fixAll"
            --   local cur_buf_name = vim.api.nvim_buf_get_name(bufnr)
            --   local params = {
            --     command = command,
            --     arguments = { { path = cur_buf_name } },
            --     title = "",
            --   }
            --
            --   if isPreflight then
            --     vim.lsp.buf_request(
            --       bufnr,
            --       "workspace/executeCommand",
            --       params,
            --       function() end
            --     )
            --     return
            --   end
            --   vim.lsp.buf_request_sync(
            --     bufnr,
            --     "workspace/executeCommand",
            --     params,
            --     3000
            --   )
            -- end

            -- local bufnr = vim.api.nvim_get_current_buf()
            -- hack: Preflight async request to dartls, which can prevent blocking when save buffer on first time opened
            -- dart_fix_all(bufnr, true)
            vim.api.nvim_create_autocmd("BufWritePre", {
              pattern = "*.dart",
              group = vim.api.nvim_create_augroup("LspDartFixAll", {}),
              callback = function(args)
                vim.lsp.buf.code_action({
                  context = {
                    only = { "source.fixAll" },
                    diagnostics = {},
                  },
                  apply = true,
                })
                -- dart_fix_all(args.buf)
              end,
            })
            require("telescope").load_extension("flutter")
          end,
          color = {
            enabled = true,
            background = false,
            background_color = { r = 19, g = 17, b = 24 },
            foreground = false,
            virtual_text = true,
            virtual_text_str = "■",
          },
          settings = {
            showTodos = false,
            completeFunctionCalls = true,
            updateImportsOnRename = true,
            enableSnippets = true,
            renameFilesWithClasses = "prompt",
            analysisExcludedFolders = {},
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
          register_configurations = function(_)
            local is_windows = vim.fn.has("win32") > 0
            local path_sep = is_windows and "\\" or "/"
            local flutter_exec = is_windows and "flutter.bat" or "flutter"
            local dap = require("dap")
            local flutterBin = vim.fn.resolve(vim.fn.exepath(flutter_exec))
            local flutterSdk = vim.fn.fnamemodify(flutterBin, ":h:h")
            local dartSdk = flutterSdk
              .. path_sep
              .. "bin"
              .. path_sep
              .. "cache"
              .. path_sep
              .. "dart-sdk"

            if is_windows then
              dap.adapters.dart = {
                type = "executable",
                command = vim.fn.exepath("cmd.exe"),
                args = { "/c", flutterBin, "debug_adapter" },
                options = {
                  detached = false,
                  initialize_timeout_sec = 10,
                },
              }
            end

            require("dap.ext.vscode").load_launchjs()

            -- if dap configurations were empty, then we can set this default one
            if not dap.configurations.dart then
              dap.configurations.dart = {
                {
                  type = "dart",
                  request = "launch",
                  name = "Launch dart",
                  dartSdkPath = dartSdk,
                  flutterSdkPath = flutterSdk,
                  program = "${workspaceFolder}"
                    .. path_sep
                    .. "lib"
                    .. path_sep
                    .. "main.dart",
                  cwd = "${workspaceFolder}",
                },
              }
            end
          end,
        },
      })
    end,
  },
  -- {
  --   "mfussenegger/nvim-dap",
  --   opts = {},
  -- config = function()
  --   local dap = require("dap")
  --   local flutterBin = vim.fn.resolve(vim.fn.exepath("flutter.bat"))
  --   local flutterSdk = vim.fn.fnamemodify(flutterBin, ":h:h")
  --   local dartSdk = flutterSdk .. "\\bin\\cache\\dart-sdk"
  --
  --   dap.adapters.dart = {
  --     type = "executable",
  --     command = vim.fn.exepath("cmd.exe"),
  --     args = { "/c", flutterBin, "debug_adapter" },
  --     options = {
  --       detached = false,
  --       initialize_timeout_sec = 10,
  --     },
  --   }
  --
  --   dap.configurations.dart = {
  --     {
  --       type = "dart",
  --       request = "launch",
  --       name = "Launch dart",
  --       dartSdkPath = dartSdk,
  --       flutterSdkPath = flutterSdk,
  --       program = "${workspaceFolder}\\lib\\main.dart",
  --       cwd = "${workspaceFolder}",
  --     },
  --   }
  --
  --   require("dap.ext.vscode").load_launchjs()
  -- end,
  -- },
}
