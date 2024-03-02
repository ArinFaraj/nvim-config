return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      use_libuv_file_watcher = false,
    },
    window = {
      mappings = {
        ["O"] = {
          command = function(state)
            local node = state.tree:get_node()
            local filepath = node.path
            local osType = os.getenv("OS")

            local command

            if osType == "Windows_NT" then
              command = "start " .. filepath
            elseif osType == "Darwin" then
              command = "open " .. filepath
            else
              command = "xdg-open " .. filepath
            end
            os.execute(command)
          end,
          desc = "open_with_system_defaults",
        },
      },
    },
  },
}
