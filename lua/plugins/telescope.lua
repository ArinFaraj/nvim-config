local telescope = require("telescope")
local sorters = require("telescope.sorters")
local fzy_sorter = sorters.get_fzy_sorter()
local filter = vim.tbl_filter

-- Copied from:
-- https://github.com/nvim-telescope/telescope.nvim/blob/dc192faceb2db64231ead71539761e055df66d73/lua/telescope/builtin/__internal.lua#L17-L29
local function apply_cwd_only_aliases(opts)
  local has_cwd_only = opts.cwd_only ~= nil
  local has_only_cwd = opts.only_cwd ~= nil

  if has_only_cwd and not has_cwd_only then
    -- Internally, use cwd_only
    opts.cwd_only = opts.only_cwd
    opts.only_cwd = nil
  end

  return opts
end
-- Copied from:
-- https://github.com/nvim-telescope/telescope.nvim/blob/dc192faceb2db64231ead71539761e055df66d73/lua/telescope/builtin/__internal.lua#L872-L923
local get_buffers = function(opts)
  opts = opts or {}
  opts = apply_cwd_only_aliases(opts)
  local bufnrs = filter(function(b)
    if 1 ~= vim.fn.buflisted(b) then
      return false
    end
    -- only hide unloaded buffers if opts.show_all_buffers is false, keep them listed if true or nil
    if opts.show_all_buffers == false and not vim.api.nvim_buf_is_loaded(b) then
      return false
    end
    if opts.ignore_current_buffer and b == vim.api.nvim_get_current_buf() then
      return false
    end
    if
      opts.cwd_only
      and not string.find(vim.api.nvim_buf_get_name(b), vim.loop.cwd(), 1, true)
    then
      return false
    end
    if
      not opts.cwd_only
      and opts.cwd
      and not string.find(vim.api.nvim_buf_get_name(b), opts.cwd, 1, true)
    then
      return false
    end
    return true
  end, vim.api.nvim_list_bufs())
  if not next(bufnrs) then
    return
  end
  if opts.sort_mru then
    table.sort(bufnrs, function(a, b)
      return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
    end)
  end

  local buffers = {}
  for _, bufnr in ipairs(bufnrs) do
    local flag = bufnr == vim.fn.bufnr("") and "%"
      or (bufnr == vim.fn.bufnr("#") and "#" or " ")

    local element = {
      bufnr = bufnr,
      flag = flag,
      info = vim.fn.getbufinfo(bufnr)[1],
    }

    if opts.sort_lastused and (flag == "#" or flag == "%") then
      local idx = ((buffers[1] ~= nil and buffers[1].flag == "%") and 2 or 1)
      table.insert(buffers, idx, element)
    else
      table.insert(buffers, element)
    end
  end
  return buffers
end

local is_file_open = function(line)
  local buffers = get_buffers()
  if not buffers then
    return false
  end
  -- TODO: This may not be performant if there are many open buffers.
  -- We could implement a map / lookup table instead.
  for _, buffer in ipairs(buffers) do
    local buffer_name = buffer.info.name
    if vim.endswith(buffer_name, line) then
      return true
    end
  end
  return false
end

-- Copied from:
-- https://github.com/nvim-telescope/telescope.nvim/blob/dc192faceb2db64231ead71539761e055df66d73/lua/telescope/sorters.lua#L437-L466
-- Sorter using the fzy algorithm
local file_sorter = function(opts)
  opts = opts or {}
  local fzy = opts.fzy_mod or require("telescope.algos.fzy")
  local OFFSET = -fzy.get_score_floor()

  return sorters.Sorter:new({
    discard = fzy_sorter.discard,

    scoring_function = function(_, prompt, line)
      -- Check for actual matches before running the scoring alogrithm.
      if not fzy.has_match(prompt, line) then
        return -1
      end

      local fzy_score = fzy.score(prompt, line)

      -- The fzy score is -inf for empty queries and overlong strings.  Since
      -- this function converts all scores into the range (0, 1), we can
      -- convert these to 1 as a suitable "worst score" value.
      if fzy_score == fzy.get_score_min() then
        return 1
      end

      -- CUSTOM CODE ADDED HERE 👇
      -- Double score if file is open.
      -- TODO: Score boost could take into account sort order of buffers.
      -- Like which one was last used.
      if is_file_open(line) then
        fzy_score = fzy_score * 2
      end
      -- END CUSTOM CODE

      -- Poor non-empty matches can also have negative values. Offset the score
      -- so that all values are positive, then invert to match the
      -- telescope.Sorter "smaller is better" convention. Note that for exact
      -- matches, fzy returns +inf, which when inverted becomes 0.
      return 1 / (fzy_score + OFFSET)
    end,

    highlighter = fzy_sorter.highlighter,
  })
end
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
local function telescope_c(builtin, opts)
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

return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_sorter = file_sorter,
    },
    pickers = {
      find_files = {
        path_display = filenameFirst,
      },
    },
  },
  keys = {
    {
      "<leader><space>",
      -- '<cmd>Telescope frecency path_display={"filename_first"}<cr>',
      telescope_c(
        "files",
        { path_display = filenameFirst, file_sorter = file_sorter }
      ),
      desc = "Find Files (Root Dir)",
    },
    {
      "<leader>ff",
      telescope_c("files"),
      desc = "Find Files (Root Dir)",
    },
    {
      "<leader>fF",
      telescope_c("files", { cwd = false, path_display = filenameFirst }),

      desc = "Find Files (cwd)",
    },
  },
}
