-- ── Markdown: переключение режима редактирования/просмотра ──────────────────
-- • <leader>mr — «режим просмотра»: рендерит ВСЮ разметку markdown в буфере
--   как отдельную страницу (заголовки/иконки, чекбоксы, ссылки, таблицы,
--   цитаты, код, латекс и т.д.), прячет номера строк и включает перенос.
--   Повторное нажатие — «режим редактирования» (исходный синтаксис).
-- • <leader>mp — превью в браузере (markdown-preview.nvim).
-- Спеки объединяются с extra `lazyvim.plugins.extras.lang.markdown`.

local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Markdown" })
end

-- ── MD-линтер (markdownlint): вкл/выкл все ошибки ────────────────────────────
M.md_lint_on = true

local function toggle_md_lint()
  M.md_lint_on = not M.md_lint_on
  local ok, lint = pcall(require, "lint")
  if ok then
    if M.md_lint_on then
      -- Включили: перезапустить линтер (condition уже true)
      lint.try_lint()
    else
      -- Выключили: очистить уже показанные ошибки.
      -- НЕ вызываем try_lint() — он запустил бы линтер в обход condition.
      vim.diagnostic.reset(nil, { namespace = lint.get_namespace("markdownlint-cli2") })
    end
  end
  notify(M.md_lint_on and "MD-линтер включён" or "MD-линтер отключён (все ошибки скрыты)",
    M.md_lint_on and vim.log.levels.INFO or vim.log.levels.WARN)
end

-- ── Окно «режима просмотра» ─────────────────────────────────────────────────
M.saved_win = {} -- bufnr -> сохранённые настройки окна

local function view_on()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local w = vim.wo[win]
  M.saved_win[buf] = {
    number = w.number,
    relativenumber = w.relativenumber,
    wrap = w.wrap,
    conceallevel = w.conceallevel,
    concealcursor = w.concealcursor,
    colorcolumn = w.colorcolumn,
    signcolumn = w.signcolumn,
  }
  -- Прячем «лишнее» для вида как у страницы
  vim.wo[win].nu = false
  vim.wo[win].rnu = false
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 3
  vim.wo[win].concealcursor = ""
  vim.wo[win].colorcolumn = ""
  vim.wo[win].signcolumn = "no"
end

local function view_off()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local saved = M.saved_win[buf]
  if not saved then
    return
  end
  for k, v in pairs(saved) do
    vim.wo[win][k] = v
  end
  M.saved_win[buf] = nil
end

-- ── Переключение режимов ────────────────────────────────────────────────────
local function toggle_render()
  local ok, rm = pcall(require, "render-markdown")
  if not ok then
    notify("render-markdown не загружен", vim.log.levels.WARN)
    return
  end
  if rm.get() then
    rm.disable()
    view_off()
    notify("Режим редактирования")
  else
    rm.enable()
    view_on()
    notify("Режим просмотра")
  end
end

return {
  -- Полный рендер markdown в буфере
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- Переопределяем часть opts из LazyVim extra, чтобы включить все разметки:
    -- иконки заголовков, чекбоксы; остальное уже включено по умолчанию
    -- (ссылки, таблицы, цитаты, списки, код, латекс, callout, html, yaml).
    opts = {
      -- По умолчанию markdown открывается в режиме редактирования (без рендера).
      -- «Режим просмотра» включается только по <leader>mr — иначе первое нажатие
      -- хоткея выключало бы уже включённый рендер (LazyVim включает его сам).
      enabled = false,
      heading = {
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      checkbox = { enabled = true },
      -- В режиме просмотра рендер остаётся и на строке курсора (как страница),
      -- raw-синтаксис виден только в «режиме редактирования»
      anti_conceal = { enabled = false },
    },
    keys = {
      {
        "<leader>mr",
        function()
          toggle_render()
        end,
        ft = "markdown",
        desc = "📖 Просмотр ⇄ редактирование",
      },
      { "<leader>mD", toggle_md_lint, desc = "🚫 Показать / скрыть все MD-ошибки" },
    },
  },

  -- Превью в браузере
  {
    "iamcco/markdown-preview.nvim",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "🌐 Превью в браузере" },
    },
  },

  -- Линтер markdown: отключаем MD031/MD029 (см. ~/.markdownlint-cli2.yaml)
  -- и даём хоткей <leader>mD для полного вкл/выкл всех MD-ошибок
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters["markdownlint-cli2"] = {
        args = { "-", "--config", vim.fn.expand("~/.markdownlint-cli2.yaml") },
        condition = function()
          return M.md_lint_on
        end,
      }
      return opts
    end,
  },
}