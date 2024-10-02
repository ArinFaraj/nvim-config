return {
  "yioneko/nvim-cmp",
  branch = "perf-up",
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local cmp = require("cmp")
    -- table.insert(opts.sources, 1, {
    --   name = "supermaven",
    --   group_index = 1,
    --   priority = 100,
    -- })
    opts.completion = {
      completeopt = "menu,menuone,noinsert,noselect",
    }
    opts.mapping = cmp.mapping.preset.insert({
      ["<CR>"] = cmp.mapping.confirm({
        select = false,
      }),
    })
  end,
}
