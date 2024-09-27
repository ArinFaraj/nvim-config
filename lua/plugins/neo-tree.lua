return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
      },
      use_libuv_file_watcher = false,
    },
    window = {
      position = "right",
      mappings = {
        ["O"] = {
          command = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()

            local open_command
            if vim.fn.has("mac") == 1 then
              -- macOS: open file in default application in the background
              open_command = { "open", "-g", path }
              -- or use xdg-open if the above command doesn't work
              -- open_command = { "xdg-open", "-g", path }
            elseif vim.fn.has("unix") == 1 then
              -- Linux: open file in default application
              open_command = { "xdg-open", path }
            elseif vim.fn.has("win32") == 1 then
              -- Windows: open file in explorer
              -- Remove the file from the path to open the containing folder
              local folder_path = vim.fn.fnamemodify(path, ":h")
              open_command = { "cmd", "/c", "start", "explorer", folder_path }
            else
              vim.notify("Unsupported operating system", vim.log.levels.ERROR)
              return
            end

            vim.fn.jobstart(open_command, { detach = true })
          end,
          desc = "open_with_system_defaults",
        },
      },
    },
  },
}
