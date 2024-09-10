return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        indicator = {
          icon = "", -- this should be omitted if indicator style is not 'icon'
          style = "icon",
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = {
          skip = true,
        },
      })

      opts.presets.lsp_doc_border = true
    end,
  },
  {
    "nvimdev/dashboard-nvim",
    lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
    opts = function(_, opts)
      local logo = [[
⠀              ⠀⠀⠀⠀⠀⠀⠀⢰⡆⠀⠀⠀⠀⠀⠀⠀             ⠀
⠀⠀⠀⠀              ⠀⠀⠀⢠⣿⣿⡄⠀⠀⠀⠀⠀⠀             ⠀
⠀              ⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⡄⠀⠀⠀⠀⠀             ⠀
⠀              ⠀⠀⠀⠀⢠⣾⣷⣽⣿⣿⣿⡄⠀⠀⠀⠀             ⠀
⠀⠀              ⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀             ⠀
⠀              ⠀⠀⢠⣿⣿⣿⡟⠉⠉⢻⣿⣿⣿⡄⠀⠀             ⠀
⠀              ⠀⢠⣿⣿⣿⣿⠀⠀⠀⠀⣿⣿⣿⡻⡄⠀⠀ |_  _|_     
⠀              ⣰⣿⣿⠿⠟⠛⠀⠀⠀⠀⠻⠿⠿⣿⣶⡄⠀ |_)  |_ \/\/
⠀         ⠀  ⠀⡠⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⢄⠀⠀          ⠀
    ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      opts.config.header = vim.split(logo, "\n")
      return opts
    end,
  },
}
