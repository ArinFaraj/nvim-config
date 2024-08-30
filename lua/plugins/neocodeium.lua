return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  config = function()
    local neocodeium = require("neocodeium")
    neocodeium.setup()
    vim.keymap.set("i", "<C-y>", neocodeium.accept)
    vim.keymap.set("i", "<C-l>", neocodeium.cycle)
  end,
}
