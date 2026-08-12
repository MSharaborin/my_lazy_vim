-- ── Базы данных: PostgreSQL + MongoDB через vim-dadbod ───────────────────────
-- Формат строк подключения:
--   PostgreSQL: postgresql://user:password@host:5432/database
--   MongoDB:    mongodb://user:password@host:27017/database
--   SQLite:     sqlite:path/to/file.db

-- Обновлять список подключений из connections.json при каждом открытии панели.
-- vim-dadbod-ui кэширует список на сессию, иначе новое подключение видно только после рестарта.
local function go_dbui_toggle()
  local open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "dbui" then
      open = true
      break
    end
  end
  if not open then
    pcall(vim.fn["db_ui#reset_state"])
  end
  vim.cmd("DBUIToggle")
end

return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      {
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "plsql" },
        lazy = true,
      },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>Db", go_dbui_toggle, desc = "🗄️  База данных (панель)" },
      { "<leader>Da", "<cmd>DBUIAddConnection<cr>", desc = "➕ Добавить подключение" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "🔍 Найти буфер БД" },
      { "<leader>Dr", "<cmd>DBUIRenameBuffer<cr>", desc = "✏️  Переименовать буфер" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/nvim/db_ui")

      vim.g.db_ui_table_helpers = {
        postgresql = {
          Count = "SELECT COUNT(*) FROM {optional_schema}{table}",
          Explain = "EXPLAIN ANALYZE {last_query}",
          List = "SELECT * FROM {optional_schema}{table} LIMIT 100",
        },
        mongodb = {
          Count = "db.{table}.countDocuments({})",
          List = "db.{table}.find({}).limit(50)",
        },
      }

      vim.g.db_ui_icons = {
        expanded = {
          db = "▾ 🗄️ ",
          buffers = "▾ 📄",
          saved_queries = "▾ 💾",
          schemas = "▾ 📁",
          schema = "▾ 📂 ",
          tables = "▾ 📋",
          table = "▾ 📊 ",
        },
        collapsed = {
          db = "▸ 🗄️ ",
          buffers = "▸ 📄",
          saved_queries = "▸ 💾",
          schemas = "▸ 📁",
          schema = "▸ 📂 ",
          tables = "▸ 📋",
          table = "▸ 📊 ",
        },
        saved_query = "💾 ",
        new_query = "➕ ",
        tables = "📋 ",
        buffers = "📄 ",
        connection_ok = "✅ ",
        connection_error = "❌ ",
      }
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function(event)
          local opts = { buffer = event.buf, silent = true }
          vim.keymap.set(
            "n",
            "<leader>Dq",
            "<Plug>(DBUI_ExecuteQuery)",
            vim.tbl_extend("force", opts, { desc = "▶  Выполнить запрос" })
          )
          vim.keymap.set(
            "v",
            "<leader>Dq",
            "<Plug>(DBUI_ExecuteQuery)",
            vim.tbl_extend("force", opts, { desc = "▶  Выполнить выделение" })
          )
          vim.keymap.set(
            "n",
            "<leader>Ds",
            "<Plug>(DBUI_SaveQuery)",
            vim.tbl_extend("force", opts, { desc = "💾 Сохранить запрос" })
          )
          vim.keymap.set(
            "n",
            "<leader>De",
            "<Plug>(DBUI_EditBindParameters)",
            vim.tbl_extend("force", opts, { desc = "✏️  Параметры запроса" })
          )
        end,
      })
    end,
  },

  -- Автодополнение SQL через blink.cmp + vim-dadbod-completion
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          sql = { "snippets", "dadbod", "buffer" },
          mysql = { "snippets", "dadbod", "buffer" },
          plsql = { "snippets", "dadbod", "buffer" },
        },
        providers = {
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
        },
      },
    },
  },
}
