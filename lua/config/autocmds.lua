-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ── Терминал ──────────────────────────────────────────────────────────────────
local user_term_group = vim.api.nvim_create_augroup("user_term_no_mouse", { clear = true })
local user_default_mouse

local function user_update_mouse()
  if vim.bo.buftype == "terminal" then
    if user_default_mouse == nil then
      user_default_mouse = vim.o.mouse
    end
    vim.o.mouse = ""
  elseif user_default_mouse ~= nil then
    vim.o.mouse = user_default_mouse
    user_default_mouse = nil
  end
end

vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  group = user_term_group,
  callback = user_update_mouse,
})
