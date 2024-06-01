return {
  { "sidlatau/neotest-dart", lazy = false },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "sidlatau/neotest-dart",
    },
    opts = function(_, opts)
      table.insert(
        opts.adapters,
        require("neotest-dart")({
          command = "flutter",
          use_lsp = true,
          -- custom_test_method_names = {},
        })
      )
      return opts
    end,
  },
}
