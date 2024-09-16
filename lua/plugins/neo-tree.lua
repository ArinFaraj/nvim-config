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
            -- macOs: open file in default application in the background.
            vim.fn.jobstart({ "xdg-open", "-g", path }, { detach = true })
            -- Linux: open file in default application
            vim.fn.jobstart({ "xdg-open", path }, { detach = true })

            -- Windows: Without removing the file from the path, it opens in code.exe instead of explorer.exe
            local p
            local lastSlashIndex = path:match("^.+()\\[^\\]*$") -- Match the last slash and everything before it
            if lastSlashIndex then
              p = path:sub(1, lastSlashIndex - 1) -- Extract substring before the last slash
            else
              p = path -- If no slash found, return original path
            end
            vim.cmd("silent !start explorer " .. p)
          end,
          desc = "open_with_system_defaults",
        },
      },
    },
  },
}
