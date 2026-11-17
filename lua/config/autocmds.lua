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

-- ── Режим: выход из плавающего окна сбрасывает режим в Normal ────────────────
-- При копировании мышью из плавающего окна (mouse="a") nvim уходит в visual
-- mode. Если окно при уходе автозакрывается (neotest-output с auto_close,
-- пикеры и т.п.), визуальный режим «утекает» в окно редактора: Space перестаёт
-- работать как leader, команды не выполняются, помогает только перезапуск.
-- Сброс режима при уходе из float'а лечит это для всех плавающих окон сразу.
local user_mode_group = vim.api.nvim_create_augroup("user_float_reset_mode", { clear = true })

vim.api.nvim_create_autocmd("WinLeave", {
  group = user_mode_group,
  callback = function()
    -- срабатывает только для плавающих окон (пикеры, вывод тестов, gitgraph…)
    if vim.api.nvim_win_get_config(0).relative == "" then
      return
    end
    local m = vim.fn.mode()
    if m:find("^[iR]") then -- insert / replace
      vim.cmd("stopinsert")
    elseif m:find("^[vV\22]") then -- v, V, Ctrl-V (visual)
      vim.cmd([[execute "normal! \<Esc>"]])
    end
  end,
})

-- Второй рубеж: вход в ОБЫЧНОЕ окно из плавающего тоже сбрасывает visual.
-- Иначе протаскивание выделения мышью из float'а в редактор после WinLeave
-- успевает заново включить visual уже в окне редактора.
vim.api.nvim_create_autocmd("WinEnter", {
  group = user_mode_group,
  callback = function()
    if vim.api.nvim_win_get_config(0).relative ~= "" then
      return -- вошли в другое плавающее окно — не трогаем
    end
    local m = vim.fn.mode()
    if m:find("^[vV\22]") then
      vim.cmd([[execute "normal! \<Esc>"]])
    end
  end,
})

-- Диагностика при повторении бага «Space перестаёт работать как leader»:
-- команда показывает текущий режим, плавающее ли окно и живы ли Space-маппинги.
vim.api.nvim_create_user_command("DebugMode", function()
  local m = vim.fn.mode(1)
  local in_float = vim.api.nvim_win_get_config(0).relative ~= ""
  local n_space = 0
  for _, km in ipairs(vim.api.nvim_get_keymap("n")) do
    if km.lhs:find("^ ", 1) then
      n_space = n_space + 1
    end
  end
  vim.notify(
    ("mode=%s | float=%s | Space-маппингов=%d"):format(m, tostring(in_float), n_space),
    vim.log.levels.INFO,
    { title = "DebugMode" }
  )
end, { desc = "Диагностика режима и leader-маппингов" })
