-- ── Шпаргалка: читает ~/.config/nvim/CHEATSHEET.md ───────────────────────────
-- Открыть: <F1> / <leader>K / <leader>hk
-- Редактировать текст справки: файл CHEATSHEET.md рядом с этим конфигом

local function read_cheatsheet_lines()
  local path = vim.fn.stdpath("config") .. "/CHEATSHEET.md"
  local f = io.open(path, "r")
  if not f then
    return {
      "# Справка не найдена",
      "",
      "Ожидался файл: " .. path,
      "Открой его вручную или переустанови конфиг.",
    }
  end
  local content = f:read("*a")
  f:close()
  -- Для читаемости в float: убрать markdown-таблицы-разделители не обязательно
  return vim.split(content, "\n", { plain = true })
end

local function open_cheatsheet()
  local lines = read_cheatsheet_lines()

  local ok_snacks, Snacks = pcall(require, "snacks")
  if ok_snacks and Snacks.win then
    Snacks.win({
      file = false,
      enter = true,
      width = 0.78,
      height = 0.88,
      border = "rounded",
      title = " 📚 Справка Neovim (q / Esc закрыть) ",
      title_pos = "center",
      bo = {
        filetype = "markdown",
        buftype = "nofile",
        bufhidden = "wipe",
      },
      wo = {
        wrap = true,
        linebreak = true,
        cursorline = true,
        number = false,
        relativenumber = false,
        signcolumn = "no",
        conceallevel = 2,
      },
      keys = {
        q = "close",
        ["<Esc>"] = "close",
        ["<F1>"] = "close",
      },
      on_buf = function(self)
        vim.bo[self.buf].modifiable = true
        vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
        vim.bo[self.buf].modifiable = false
        vim.bo[self.buf].readonly = true
      end,
    })
    return
  end

  -- Fallback без Snacks
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true

  local width = math.floor(vim.o.columns * 0.78)
  local height = math.floor(vim.o.lines * 0.88)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " 📚 Справка Neovim ",
    title_pos = "center",
  })
  vim.wo[win].wrap = true
  vim.wo[win].cursorline = true

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<F1>", close, { buffer = buf, nowait = true })
end

_G.EvroCheatsheet = open_cheatsheet

return {
  {
    "folke/which-key.nvim",
    lazy = false, -- грузить сразу: иначе при сбое VeryLazy Space ведёт себя как «движение вправо»
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { "<leader>d", group = "🐛 Отладка", icon = "🐛" },
        { "<leader>k", group = "🐳 Docker", icon = "🐳" },
        { "<leader>T", group = "📟 Терминал", icon = "📟" },
        { "<leader>p", group = "🐍 Python", icon = "🐍" },
        { "<leader>r", group = "🔄 REPL (Python)", icon = "🔄" },
        { "<leader>R", group = "🦀 Rust", icon = "🦀" },
        { "<leader>g", group = "🌿 Git", icon = "🌿" },
        { "<leader>mc", group = "🔀 Merge-конфликт", icon = "🔀" },
        { "<leader>D", group = "🗄️  Базы данных", icon = "🗄️" },
        { "<leader>t", group = "🧪 Тесты", icon = "🧪" },
        { "<leader>G", group = "🐹 Go", icon = "🐹" },
        { "<leader>h", group = "❓ Справка", icon = "❓" },
        { "<leader>c", group = "💡 Код / LSP", icon = "💡" },
        { "<leader>u", group = "🎨 UI / Вид", icon = "🎨" },
        { "<leader>s", group = "🔍 Поиск", icon = "🔍" },
        { "<leader>f", group = "📁 Файлы", icon = "📁" },
        { "<leader>b", group = "📄 Буферы", icon = "📄" },
        { "<leader>e", group = "📂 Explorer", icon = "📂" },
        { "<leader>w", group = "🪟 Окна", icon = "🪟" },
        { "<leader>q", group = "⏻  Выход", icon = "⏻" },
        { "<leader>x", group = "⚠️  Диагностика", icon = "⚠️" },

        { "<leader>hk", desc = "📚 Открыть справку" },
        { "<leader>K", desc = "📚 Открыть справку" },
        { "<F1>", desc = "📚 Открыть справку" },
        { "<leader>cv", desc = "🐍 Выбрать Python venv" },
        { "<leader>pr", desc = "🚀 Запустить Python файл" },
        { "<leader>pR", desc = "🚀 Python с аргументами" },
        { "<leader>pf", desc = "🔧 Ruff: исправить всё" },
        { "<leader>pi", desc = "📦 Ruff: упорядочить импорты" },
        { "<leader>pF", desc = "🎨 Ruff: форматировать" },
        { "<leader>px", desc = "🔧 Ruff CLI: check --fix" },
        { "<leader>ef", desc = "📁 Neo-tree: Файлы" },
        { "<leader>eb", desc = "📄 Neo-tree: Буферы" },
        { "<leader>eg", desc = "🌿 Neo-tree: Git" },
        { "<leader>bd", desc = "❌ Закрыть буфер" },
        { "<leader>bo", desc = "❌ Закрыть другие буферы" },
        { "<leader>bD", desc = "❌ Закрыть буфер принудительно" },
        { "<leader>gm", desc = "🔀 Merge UI (как PyCharm)" },
        { "<leader>mcr", desc = "🔀 Открыть Merge UI" },
        { "<leader>mco", desc = "✅ Принять своё (OURS)" },
        { "<leader>mct", desc = "✅ Принять чужое (THEIRS)" },
        { "<leader>mcb", desc = "✅ Принять оба" },
        { "<leader>mc0", desc = "🗑 Ничего не брать" },
        { "<leader>mcl", desc = "📋 Список конфликтов" },
        { "]x", desc = "➡ Следующий конфликт" },
        { "[x", desc = "⬅ Предыдущий конфликт" },
      })
      opts.preset = opts.preset or "modern"
      opts.delay = 300
      return opts
    end,
    keys = {
      {
        "<F1>",
        function()
          open_cheatsheet()
        end,
        mode = { "n", "i", "v" },
        desc = "📚 Справка",
      },
      {
        "<leader>K",
        function()
          open_cheatsheet()
        end,
        desc = "📚 Справка",
      },
      {
        "<leader>hk",
        function()
          open_cheatsheet()
        end,
        desc = "📚 Справка",
      },
      {
        "<leader>?",
        function()
          vim.schedule(function()
            require("which-key").show({ global = false })
          end)
        end,
        desc = "📚 which-key (буфер)",
      },
    },
  },
}
