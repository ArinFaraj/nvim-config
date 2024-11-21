local function list_insert_unique(dst, src)
  if not dst then
    dst = {}
  end

  local added = {}
  for _, val in ipairs(dst) do
    added[val] = true
  end
  for _, val in ipairs(src) do
    if not added[val] then
      table.insert(dst, val)
      added[val] = true
    end
  end
  return dst
end
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
          -- vim.o.modifiable = true
          vim.g.baleia.automatically(vim.api.nvim_get_current_buf())
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
      -- "Nash0x7E2/awesome-flutter-snippets",
      -- "RobertBrunhage/flutter-riverpod-snippets",
    },
    config = function()
      local register_keys = function()
        local wk = require("which-key")

        wk.add({
          { "<leader>m", name = "+dart", icon = "" },
          {
            "<leader>md",
            "<cmd>FlutterDevices<cr>",
            desc = "Flutter Devices (Run)",
          },
          { "<leader>mm", "<cmd>FlutterRun<cr>", desc = "Flutter Run" },
          {
            "<leader>mo",
            "<cmd>FlutterOutlineToggle<cr>",
            desc = "Flutter Outline",
          },
          { "<leader>mq", "<cmd>FlutterQuit<cr>", desc = "Flutter Quit" },
          { "<leader>mr", "<cmd>FlutterRestart<cr>", desc = "Flutter Restart" },
          { "<leader>mp", "<cmd>FlutterPubGet<cr>", desc = "Flutter Pub Get" },
          {
            "<leader>mP",
            "<cmd>FlutterPubUpgrade<cr>",
            desc = "Flutter Pub Upgrade",
          },
          {
            "<leader>ml",
            "<cmd>FlutterLogClear<cr>",
            desc = "Flutter Log Clear",
          },
          { "<leader>me", "<cmd>FlutterEmulators<cr>", desc = "Emulators" },
          {
            "<leader>mc",
            "<cmd>FlutterOpenDevTools<cr><cmd>FlutterCopyProfilerUrl<cr>",
            desc = "Open Devtools & Copy Profiler Url",
          },
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
          notify_errors = false,
          filter = function(
            log_line --[[string]]
          )
            local ignored = {
              "D/TrafficStats",
              "D/ViewRootImplExtImpl",
              "D/VRI",
              "W/VRI",
              "EGL_emulation",
              "W/WindowOnBackDispatcher",
              "I/TransportRuntime",
              "W/ViewRootImpl",
              "D/InputMethodManager",
              "V/AutofillManager",
              "I/SurfaceControl",
              "Attempt to remove non-JNI",
            }

            for _, v in ipairs(ignored) do
              if log_line:find(v) then
                return false
              end
            end
            return true
          end,
          open_cmd = "edit",
          -- open_cmd = "botright 5sp",
        },
        dev_tools = {
          autostart = true,
          auto_open_browser = false,
        },
        fvm = true,
        lsp = {
          on_attach = function()
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
                vim.cmd("write")
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
            showTodos = true,
            completeFunctionCalls = true,
            updateImportsOnRename = true,
            enableSnippets = true,
            experimentalRefactors = true,
            renameFilesWithClasses = "always",
            analysisExcludedFolders = {
              -- ".dart_tool",
              -- "/Users/ts/.pub-cache/",
              -- "/Users/ts/fvm/",
            },
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = false,
          exception_breakpoints = {},
          register_configurations = function(_)
            local dap = require("dap")

            local is_windows = vim.fn.has("win32") > 0
            -- local path_sep = is_windows and "\\" or "/"
            local flutter_exec = is_windows and "flutter.bat" or "flutter"
            local flutterBin = vim.fn.resolve(vim.fn.exepath(flutter_exec))
            -- local flutterSdk = vim.fn.fnamemodify(flutterBin, ":h:h")
            -- local dartSdk = flutterSdk
            --   .. path_sep
            --   .. "bin"
            --   .. path_sep
            --   .. "cache"
            --   .. path_sep
            --   .. "dart-sdk"

            if is_windows then
              dap.adapters.dart = {
                type = "executable",
                command = vim.fn.exepath("cmd.exe"),
                args = { "/c", flutterBin, "debug_adapter" },
                enrich_config = function(conf, on_config)
                  local new_config =
                    vim.tbl_deep_extend("force", conf, { stopOnEntry = false })
                  on_config(new_config)
                end,
                options = {
                  detached = false,
                  initialize_timeout_sec = 10,
                },
              }
            else
              dap.adapters.dart = {
                type = "executable",
                command = flutterBin,
                enrich_config = function(conf, on_config)
                  local new_config =
                    vim.tbl_deep_extend("force", conf, { stopOnEntry = false })
                  on_config(new_config)
                end,
                args = { "debug_adapter" },
                options = {
                  detached = false,
                  initialize_timeout_sec = 10,
                },
              }
            end

            -- require("dap.ext.vscode").load_launchjs()

            -- if dap configurations were empty, then we can set this default one
            -- if not dap.configurations.dart then
            -- set stopOnEntry to false to for each configuration
            -- dap.configurations.dart = {
            --   {
            --     type = "dart",
            --     request = "launch",
            --     name = "Launch dart",
            --     dartSdkPath = dartSdk,
            --     flutterSdkPath = flutterSdk,
            --     program = "${workspaceFolder}"
            --       .. path_sep
            --       .. "lib"
            --       .. path_sep
            --       .. "main.dart",
            --     cwd = "${workspaceFolder}",
            --   },
            -- }
            -- end
          end,
        },
      })

      -- do not move focus when opening log buffer
      local ui = require("flutter-tools.ui")
      local original_open_win = ui.open_win
      ---@diagnostic disable-next-line: duplicate-set-field
      ui.open_win = function(cmd, bufnr, opts)
        local current_buf = vim.api.nvim_get_current_buf()
        original_open_win(cmd, bufnr, opts)
        vim.api.nvim_set_current_buf(current_buf)
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      -- HACK: Disables the select treesitter textobjects because the Dart treesitter
      -- parser is very inefficient. Hopefully this gets fixed
      -- and this block can be removed in the future.
      -- Reference: https://github.com/AstroNvim/AstroNvim/issues/2707
      local select = vim.tbl_get(opts, "textobjects", "select")
      if select then
        select.disable = list_insert_unique(select.disable, { "dart" })
      end
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
