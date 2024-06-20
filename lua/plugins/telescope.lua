vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopeResults",
  callback = function(ctx)
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.fn.matchadd("TelescopeParent", "\t\t.*$")
      vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
    end)
  end,
})

local function filenameFirst(_, path)
  local tail = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)
  if parent == "." then
    return tail
  end
  return string.format("%s\t\t%s", tail, parent)
end

-- this will return a function that calls telescope.
-- cwd will default to lazyvim.util.get_root
-- for `files`, git_files or find_files will be chosen depending on .git
---@param builtin string
---@param opts? lazyvim.util.telescope.opts
local function telescope(builtin, opts)
  local params = { builtin = builtin, opts = opts }
  return function()
    builtin = params.builtin
    opts = params.opts
    opts = vim.tbl_deep_extend("force", { cwd = LazyVim.root() }, opts or {}) --[[@as lazyvim.util.telescope.opts]]
    if builtin == "files" then
      if
        vim.uv.fs_stat((opts.cwd or vim.uv.cwd()) .. "/.git")
        and not vim.uv.fs_stat((opts.cwd or vim.uv.cwd()) .. "/.ignore")
        and not vim.uv.fs_stat((opts.cwd or vim.uv.cwd()) .. "/.rgignore")
      then
        if opts.show_untracked == nil then
          opts.show_untracked = true
        end
        builtin = "git_files"
      else
        builtin = "find_files"
      end
    end
    if opts.cwd and opts.cwd ~= vim.uv.cwd() then
      local function open_cwd_dir()
        local action_state = require("telescope.actions.state")
        local line = action_state.get_current_line()
        telescope(
          params.builtin,
          vim.tbl_deep_extend(
            "force",
            {},
            params.opts or {},
            { cwd = false, default_text = line }
          )
        )()
      end
      ---@diagnostic disable-next-line: inject-field
      opts.attach_mappings = function(_, map)
        -- opts.desc is overridden by telescope, until it's changed there is this fix
        map("i", "<a-c>", open_cwd_dir, { desc = "Open cwd Directory" })
        return true
      end
    end

    require("telescope.builtin")[builtin](opts)
  end
end

if vim.fn.has("win32") == 1 then
  vim.g.sqlite_clib_path = "C:\\tools\\sqlite3\\sqlite3.dll"
end

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "prochri/telescope-all-recent.nvim",
      dependencies = {
        "kkharji/sqlite.lua",
      },
      opts = {},
    },
    "natecraddock/telescope-zf-native.nvim",
    "debugloop/telescope-undo.nvim",
  },
  opts = {
    pickers = {
      find_files = {
        path_display = filenameFirst,
      },
    },
  },
  config = function(_, opts)
    local tel = require("telescope")
    tel.setup(opts)
    tel.load_extension("undo")
    tel.load_extension("zf-native")
  end,
  keys = {
    {
      "<leader><space>",
      telescope("files", { path_display = filenameFirst }),
      desc = "Find Files (Root Dir)",
    },
    {
      "<leader>ff",
      telescope("files", { path_display = filenameFirst }),
      desc = "Find Files (Root Dir)",
    },
    {
      "<leader>fF",
      telescope("files", { cwd = false, path_display = filenameFirst }),
      desc = "Find Files (cwd)",
    },
    {
      "<leader>su",
      "<cmd>Telescope undo<cr>",
      desc = "Show Undo Tree",
    },
  },
}
