-- ── HTTP/REST (.rest / .http): клиент API как в PyCharm ─────────────────────
-- kulala.nvim — запрос под курсором, ответ в сплите (синтаксис, хедеры).
-- Файлы .rest и .http распознаются как filetype http.

vim.filetype.add({
  extension = {
    http = "http",
    rest = "http",
  },
})

return {
  -- ── Kulala: HTTP-клиент (<leader>H*) ────────────────────────────────────
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>Hs", "<cmd>lua require('kulala').run()<cr>", desc = "▶ Запустить запрос", ft = "http" },
      { "<leader>Hr", "<cmd>lua require('kulala').replay()<cr>", desc = "↩ Повторить последний", ft = "http" },
      { "<leader>Hi", "<cmd>lua require('kulala').inspect()<cr>", desc = "🔍 Инспекция запроса", ft = "http" },
      { "<leader>He", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "🌐 Окружение", ft = "http" },
      { "<leader>Hn", "<cmd>lua require('kulala').jump_next()<cr>", desc = "⬇ Следующий запрос", ft = "http" },
      { "<leader>Hp", "<cmd>lua require('kulala').jump_prev()<cr>", desc = "⬆ Предыдущий запрос", ft = "http" },
      { "<leader>Ht", "<cmd>lua require('kulala').toggle_view()<cr>", desc = "🔄 Заголовки/тело ответа", ft = "http" },
      { "<leader>Hq", "<cmd>lua require('kulala').close()<cr>", desc = "❌ Закрыть окно", ft = "http" },
      { "<leader>HS", "<cmd>lua require('kulala').show_stats()<cr>", desc = "📊 Статистика", ft = "http" },
      { "<leader>Hb", "<cmd>lua require('kulala').scratchpad()<cr>", desc = "📋 Черновик (scratchpad)", ft = "http" },
      { "<leader>Hc", "<cmd>lua require('kulala').copy()<cr>", desc = "📤 Копировать как cURL", ft = "http" },
      { "<leader>HC", "<cmd>lua require('kulala').from_curl()<cr>", desc = "📥 Вставить из cURL", ft = "http" },
      { "<leader>Hg", "<cmd>lua require('kulala').download_graphql_schema()<cr>", desc = "⬇ GraphQL схема", ft = "http" },
    },
    opts = {
      default_env = "development",
    },
  },

  -- ── Treesitter: парсеры http / graphql ──────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "http", "graphql" })
    end,
  },
}