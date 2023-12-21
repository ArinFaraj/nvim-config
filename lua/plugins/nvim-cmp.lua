return {
  "nvim-cmp",
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local cmp = require("cmp")
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
