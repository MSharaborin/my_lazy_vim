-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ── Быстрое сохранение ────────────────────────────────────────────────────────
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Сохранить файл" })

-- ── Навигация между окнами ────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Окно: влево" })
map("n", "<C-j>", "<C-w>j", { desc = "Окно: вниз" })
map("n", "<C-k>", "<C-w>k", { desc = "Окно: вверх" })
map("n", "<C-l>", "<C-w>l", { desc = "Окно: вправо" })

-- ── Изменение размера окон ────────────────────────────────────────────────────
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Увеличить высоту" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Уменьшить высоту" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Уменьшить ширину" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Увеличить ширину" })

-- ── Навигация по буферам ──────────────────────────────────────────────────────
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Следующий буфер" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Предыдущий буфер" })
-- Закрыть файл (буфер): Snacks не ломает раскладку окон
map("n", "<leader>bd", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.bufdelete then
    snacks.bufdelete()
  else
    vim.cmd("bdelete")
  end
end, { desc = "Закрыть буфер (файл)" })
map("n", "<leader>bo", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.bufdelete then
    snacks.bufdelete.other()
  else
    vim.cmd("%bd|e#|bd#")
  end
end, { desc = "Закрыть другие буферы" })
map("n", "<leader>bD", "<cmd>bd!<cr>", { desc = "Закрыть буфер принудительно" })

-- ── Перемещение строк ─────────────────────────────────────────────────────────
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Переместить строку вниз" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Переместить строку вверх" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Переместить строку вниз" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Переместить строку вверх" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Переместить строку вниз" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Переместить строку вверх" })

-- ── Быстрый выход из insert режима ───────────────────────────────────────────
map("i", "jk", "<Esc>", { desc = "Выйти из режима вставки" })

-- ── Поиск ─────────────────────────────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Убрать подсветку поиска" })

-- ── Выход ─────────────────────────────────────────────────────────────────────
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Выйти из Neovim" })
map("n", "<leader>qQ", "<cmd>qa!<cr>", { desc = "Выйти без сохранения" })

-- ── Буфер обмена ─────────────────────────────────────────────────────────────
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Копировать в системный буфер" })
map({ "n", "v" }, "<leader>P", '"+p', { desc = "Вставить из системного буфера" })

-- ── Отступ в визуальном режиме ───────────────────────────────────────────────
map("v", "<", "<gv", { desc = "Уменьшить отступ" })
map("v", ">", ">gv", { desc = "Увеличить отступ" })

-- ── Не перезаписывать буфер при вставке в визуальном режиме ─────────────────
map("v", "p", '"_dP', { desc = "Вставить без потери буфера" })

-- ── Центрировать при навигации ────────────────────────────────────────────────
map("n", "<C-d>", "<C-d>zz", { desc = "Прокрутить вниз (центр)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Прокрутить вверх (центр)" })
map("n", "n", "nzzzv", { desc = "Следующее совпадение (центр)" })
map("n", "N", "Nzzzv", { desc = "Предыдущее совпадение (центр)" })

-- ── LSP ───────────────────────────────────────────────────────────────────────
map("n", "K", vim.lsp.buf.hover, { desc = "Документация (hover)" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Перейти к определению" })
map("n", "gr", vim.lsp.buf.references, { desc = "Ссылки" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Реализации" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Действия с кодом" })
map("n", "<leader>cn", vim.lsp.buf.rename, { desc = "Переименовать" })
map("n", "<leader>cf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Форматировать файл" })

-- ── Диагностика ───────────────────────────────────────────────────────────────
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Предыдущая ошибка" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Следующая ошибка" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Показать ошибку" })
map("n", "<leader>cD", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Все ошибки (Trouble)" })

-- ── Шпаргалка (дублируем здесь — надёжнее, чем только через plugin keys) ──────
local function open_help()
  if _G.EvroCheatsheet then
    _G.EvroCheatsheet()
    return
  end
  -- Если плагин ещё не загрузился — открыть markdown файл
  local path = vim.fn.stdpath("config") .. "/CHEATSHEET.md"
  if vim.fn.filereadable(path) == 1 then
    vim.cmd("edit " .. path)
  else
    vim.notify("Шпаргалка не найдена. Нажмите Space затем подождите which-key.", vim.log.levels.WARN)
  end
end

map({ "n", "i", "v" }, "<F1>", open_help, { desc = "📚 Шпаргалка" })
map("n", "<leader>K", open_help, { desc = "📚 Шпаргалка" })
map("n", "<leader>hk", open_help, { desc = "📚 Шпаргалка" })
