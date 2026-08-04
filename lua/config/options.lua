-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- ── Нумерация строк ──────────────────────────────────────────────────────────
vim.opt.number = true           -- Абсолютный номер текущей строки
vim.opt.relativenumber = true   -- Относительные номера остальных строк

-- ── Отступы и табуляция ──────────────────────────────────────────────────────
vim.opt.tabstop = 4             -- Ширина таба в пробелах
vim.opt.shiftwidth = 4          -- Ширина отступа (<<, >>)
vim.opt.softtabstop = 4
vim.opt.expandtab = true        -- Заменять табы пробелами

-- ── Прокрутка ─────────────────────────────────────────────────────────────────
vim.opt.scrolloff = 8           -- Минимум строк снизу/сверху при прокрутке
vim.opt.sidescrolloff = 8       -- Минимум колонок при горизонтальной прокрутке

-- ── Внешний вид ───────────────────────────────────────────────────────────────
vim.opt.wrap = false            -- Не переносить длинные строки
vim.opt.colorcolumn = "88"      -- Линия на 88 символах (стандарт ruff/black)
vim.opt.cursorline = true       -- Подсвечивать текущую строку
vim.opt.termguicolors = true    -- 24-битные цвета
vim.opt.signcolumn = "yes"      -- Всегда показывать колонку знаков (LSP, git)
vim.opt.showmode = false        -- Не показывать -- INSERT -- (есть lualine)
vim.opt.pumblend = 10           -- Прозрачность popup меню
vim.opt.winblend = 0            -- Прозрачность плавающих окон

-- ── Мышь и буфер обмена ───────────────────────────────────────────────────────
vim.opt.mouse = "a"             -- Поддержка мыши во всех режимах
vim.opt.clipboard = "unnamedplus" -- Системный буфер обмена

-- ── Поиск ─────────────────────────────────────────────────────────────────────
vim.opt.ignorecase = true       -- Поиск без учёта регистра
vim.opt.smartcase = true        -- Но с учётом регистра если есть заглавные
vim.opt.hlsearch = true         -- Подсвечивать результаты поиска
vim.opt.incsearch = true        -- Искать по мере набора

-- ── Разделение окон ───────────────────────────────────────────────────────────
vim.opt.splitright = true       -- Вертикальный split справа
vim.opt.splitbelow = true       -- Горизонтальный split снизу

-- ── Производительность ────────────────────────────────────────────────────────
vim.opt.updatetime = 200        -- Быстрое обновление (LSP hints, git signs)
vim.opt.timeoutlen = 300        -- Время ожидания комбинации клавиш

-- ── Файловая система ──────────────────────────────────────────────────────────
vim.opt.undofile = true         -- Сохранять историю отмен между сессиями
vim.opt.swapfile = false        -- Не создавать swap файлы
vim.opt.backup = false          -- Не создавать резервные копии

-- ── Дополнительно ─────────────────────────────────────────────────────────────
vim.opt.conceallevel = 1        -- Скрывать спецсимволы в Markdown
vim.opt.list = true             -- Показывать невидимые символы
vim.opt.listchars = {
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
}
vim.opt.fillchars = {
  eob = " ",       -- Убрать ~ в конце буфера
  fold = " ",
}
