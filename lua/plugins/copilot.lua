return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" },  -- for curl, log wrapper
    },
    keys = {
      {
        "<leader>cco",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(
              input,
              { selection = require("CopilotChat.select").buffer }
            )
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      {
        "<leader>ccb",
        ":CopilotChatBuffer<cr>",
        desc = "CopilotChat - Buffer",
      },
      {
        "<leader>cce",
        "<cmd>CopilotChatExplain<cr>",
        desc = "CopilotChat - Explain code",
      },
      {
        "<leader>cct",
        "<cmd>CopilotChatTests<cr>",
        desc = "CopilotChat - Generate tests",
      },
      {
        "<leader>ccT",
        "<cmd>CopilotChatVsplitToggle<cr>",
        desc = "CopilotChat - Toggle Vsplit", -- Toggle vertical split
      },
      {
        "<leader>ccv",
        ":CopilotChatVisual",
        mode = "x",
        desc = "CopilotChat - Open in vertical split",
      },
      {
        "<leader>ccc",
        ":CopilotChatInPlace<cr>",
        mode = { "n", "x" },
        desc = "CopilotChat - Run in-place code",
      },
      {
        "<leader>ccf",
        "<cmd>CopilotChatFixDiagnostic<cr>", -- Get a fix for the diagnostic message under the cursor.
        desc = "CopilotChat - Fix diagnostic",
      },
    },
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
