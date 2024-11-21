return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        indicator = {
          -- icon = "", -- this should be omitted if indicator style is not 'icon'
          -- style = "icon",
        },
      },
    },
  },
  -- {
  --   "folke/noice.nvim",
  --   opts = function(_, opts)
  --     table.insert(opts.routes, {
  --       filter = {
  --         event = "notify",
  --         find = "No information available",
  --       },
  --       opts = {
  --         skip = true,
  --       },
  --     })
  --
  --     opts.presets.lsp_doc_border = true
  --   end,
  -- },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
⠀              ⠀⠀⠀⠀⠀⠀⠀⢰⡆⠀⠀⠀⠀⠀⠀⠀             ⠀
⠀⠀⠀⠀              ⠀⠀⠀⢠⣿⣿⡄⠀⠀⠀⠀⠀⠀             ⠀
⠀              ⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⡄⠀⠀⠀⠀⠀             ⠀
⠀              ⠀⠀⠀⠀⢠⣾⣷⣽⣿⣿⣿⡄⠀⠀⠀⠀             ⠀
⠀⠀              ⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀             ⠀
⠀              ⠀⠀⢠⣿⣿⣿⡟⠉⠉⢻⣿⣿⣿⡄⠀⠀             ⠀
⠀              ⠀⢠⣿⣿⣿⣿⠀⠀⠀⠀⣿⣿⣿⡻⡄⠀⠀ |_  _|_     
⠀              ⣰⣿⣿⠿⠟⠛⠀⠀⠀⠀⠻⠿⠿⣿⣶⡄⠀ |_)  |_ \/\/
⠀         ⠀  ⠀⡠⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⢄⠀⠀          ⠀
 ]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
        },
      },
    },
  },
}
