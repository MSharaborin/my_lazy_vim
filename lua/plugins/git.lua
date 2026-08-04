-- ── Git: Neogit + Diffview + Conflicts (как в PyCharm) + Gitsigns ────────────
-- Merge UI:
--   <leader>gm  — трёхсторонний merge (OURS | RESULT | THEIRS) как в PyCharm
--   <leader>mco / mct / mcb / mc0 — принять свою / чужую / обе / ничью
--   ]x / [x     — следующий / предыдущий конфликт
-- Частичный выбор: visual-выделение + <leader>co / <leader>ct в Diffview

return {
  -- ── Neogit ─────────────────────────────────────────────────────────────────
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "📋 Neogit (Git панель)" },
      {
        "<leader>gG",
        function()
          require("neogit").open({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "📋 Neogit (папка файла)",
      },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "✍  Git commit" },
      { "<leader>gP", "<cmd>Neogit push<cr>", desc = "⬆  Git push" },
      { "<leader>gF", "<cmd>Neogit pull<cr>", desc = "⬇  Git pull" },
    },
    config = function()
      require("neogit").setup({
        integrations = {
          diffview = true,
          telescope = true,
        },
        kind = "split",
        commit_editor = { kind = "split", show_staged_diff = true },
        commit_select_view = { kind = "tab" },
        log_view = { kind = "tab" },
        rebase_editor = { kind = "split" },
        reflog_view = { kind = "tab" },
        merge_editor = { kind = "tab" },
        tag_editor = { kind = "split" },
        preview_buffer = { kind = "split" },
        popup = { kind = "split" },
        signs = {
          hunk = { "", "" },
          item = { ">", "v" },
          section = { ">", "v" },
        },
        auto_refresh = true,
        disable_hint = false,
      })
    end,
  },

  -- ── Diffview: PyCharm-like 3-way merge ─────────────────────────────────────
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "📊 Git Diff" },
      {
        "<leader>gm",
        "<cmd>DiffviewOpen<cr>",
        desc = "🔀 Merge UI (как PyCharm)",
      },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "📜 История файла" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "📜 История репозитория" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "❌ Закрыть Diff" },
      { "<leader>gM", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "📊 Diff с HEAD~1" },
    },
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup({
        enhanced_diff_hl = true,
        show_help_hints = true,
        use_icons = true,
        view = {
          default = {
            layout = "diff2_horizontal",
            disable_diagnostics = true,
          },
          -- Как в PyCharm: слева OURS, справа THEIRS, снизу/центр RESULT
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
            winbar_info = true,
          },
          file_history = {
            layout = "diff2_horizontal",
            disable_diagnostics = true,
          },
        },
        file_panel = {
          listing_style = "tree",
          win_config = { position = "left", width = 35 },
        },
        hooks = {
          diff_buf_read = function()
            vim.opt_local.wrap = false
            vim.opt_local.list = false
            vim.opt_local.cursorline = true
          end,
        },
        keymaps = {
          disable_defaults = false,
          view = {
            { "n", "q", actions.close, { desc = "Закрыть Diffview" } },
            { "n", "<tab>", actions.select_next_entry, { desc = "Следующий файл" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Предыдущий файл" } },
            { "n", "[x", actions.prev_conflict, { desc = "⬅ Предыдущий конфликт" } },
            { "n", "]x", actions.next_conflict, { desc = "➡ Следующий конфликт" } },

            -- Принять блок целиком (курсор внутри конфликта)
            { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "✅ Принять СВОЁ (OURS)" } },
            { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "✅ Принять ЧУЖОЕ (THEIRS)" } },
            { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "✅ Принять BASE" } },
            { "n", "<leader>cB", actions.conflict_choose("all"), { desc = "✅ Принять ОБА" } },
            { "n", "dx", actions.conflict_choose("none"), { desc = "🗑 Удалить конфликт" } },

            -- Весь файл
            { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "✅ Весь файл: OURS" } },
            { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "✅ Весь файл: THEIRS" } },

            -- Частично: visual → взять выделенные строки из OURS/THEIRS
            { "v", "<leader>co", actions.diffget("ours"), { desc = "✅ Взять выделение из OURS" } },
            { "v", "<leader>ct", actions.diffget("theirs"), { desc = "✅ Взять выделение из THEIRS" } },
            { "n", "<leader>c1", actions.diffget("ours"), { desc = "✅ Взять hunk из OURS" } },
            { "n", "<leader>c2", actions.diffget("theirs"), { desc = "✅ Взять hunk из THEIRS" } },
          },
          file_panel = {
            { "n", "q", actions.close, { desc = "Закрыть" } },
            { "n", "<tab>", actions.select_next_entry, { desc = "Следующий файл" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Предыдущий файл" } },
            { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "Весь файл: OURS" } },
            { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Весь файл: THEIRS" } },
          },
        },
      })
    end,
  },

  -- ── Inline конфликты (подсветка + кнопки, как маркеры в PyCharm) ───────────
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "BufReadPost",
    opts = {
      default_mappings = false,
      default_commands = true,
      disable_diagnostics = true,
      list_opener = "copen",
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
    keys = {
      { "<leader>mco", "<Plug>(git-conflict-ours)", desc = "✅ Конфликт: принять СВОЁ" },
      { "<leader>mct", "<Plug>(git-conflict-theirs)", desc = "✅ Конфликт: принять ЧУЖОЕ" },
      { "<leader>mcb", "<Plug>(git-conflict-both)", desc = "✅ Конфликт: принять ОБА" },
      { "<leader>mc0", "<Plug>(git-conflict-none)", desc = "🗑 Конфликт: ничего" },
      { "]x", "<Plug>(git-conflict-next-conflict)", desc = "➡ Следующий конфликт" },
      { "[x", "<Plug>(git-conflict-prev-conflict)", desc = "⬅ Предыдущий конфликт" },
      { "<leader>mcl", "<cmd>GitConflictListQf<cr>", desc = "📋 Список всех конфликтов" },
      {
        "<leader>mcr",
        function()
          vim.cmd("DiffviewOpen")
          vim.notify("🔀 Merge UI открыт. Visual + <leader>co/<leader>ct = взять кусок", vim.log.levels.INFO)
        end,
        desc = "🔀 Открыть Merge UI (PyCharm-style)",
      },
    },
    config = function(_, opts)
      require("git-conflict").setup(opts)

      -- Уведомление при открытии файла с конфликтами
      vim.api.nvim_create_autocmd("User", {
        pattern = "GitConflictDetected",
        callback = function()
          vim.notify(
            "⚠️ Merge-конфликт!\n"
              .. "  <Space>mcr  — UI как в PyCharm\n"
              .. "  <Space>mco  — принять своё\n"
              .. "  <Space>mct  — принять чужое\n"
              .. "  <Space>mcb  — принять оба\n"
              .. "  ]x / [x     — след./пред. конфликт",
            vim.log.levels.WARN,
            { title = "Git Conflict", timeout = 8000 }
          )
        end,
      })
    end,
  },

  -- ── Gitsigns ───────────────────────────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts.signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      }
      opts.signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      }
      opts.current_line_blame = false
      opts.current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
      }
      opts.preview_config = { border = "rounded" }

      opts.on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.next_hunk()
          end
        end, "➡  Следующий hunk")

        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.prev_hunk()
          end
        end, "⬅  Предыдущий hunk")

        map("n", "<leader>gs", gs.stage_hunk, "✅ Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "↩  Reset hunk")
        map("v", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "✅ Stage выделение (частично)")
        map("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "↩  Reset выделение")
        map("n", "<leader>gS", gs.stage_buffer, "✅ Stage весь файл")
        map("n", "<leader>gR", gs.reset_buffer, "↩  Reset весь файл")
        map("n", "<leader>gu", gs.undo_stage_hunk, "↩  Отменить stage")
        map("n", "<leader>gp", gs.preview_hunk, "👁  Предпросмотр hunk")
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "👤 Git blame")
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "🔄 Blame inline")
        map("n", "<leader>gtd", gs.toggle_deleted, "🗑  Показать удалённые")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Выбрать hunk")
      end

      return opts
    end,
  },

  -- ── Ветки: быстрый выбор/просмотр через Telescope ──────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- <leader>gB — все ветки с превью коммита, Enter = переключиться
      {
        "<leader>gB",
        function()
          require("telescope.builtin").git_branches({ show_remote_tracking_branches = true })
        end,
        desc = "🌿 Ветки: выбрать/переключить",
      },
      -- <leader>gV — выбрать ветку и открыть Diffview с ней
      {
        "<leader>gV",
        function()
          local actions = require("telescope.actions")
          require("telescope.builtin").git_branches({
            attach_mappings = function(prompt_bufnr, map)
              map("i", "<CR>", function(prompt_bufnr)
                local entry = actions.get_selected_entry(prompt_bufnr)
                if not entry then
                  return
                end
                local branch = entry.value
                local ok, err = pcall(function()
                  actions.close(prompt_bufnr)
                  vim.defer_fn(function()
                    vim.cmd("DiffviewOpen " .. vim.fn.fnameescape(branch))
                    vim.notify("🔀 Diff с веткой: " .. branch, vim.log.levels.INFO)
                  end, 50)
                end)
                if not ok then
                  vim.notify("gV: " .. tostring(err), vim.log.levels.ERROR)
                end
              end)
              return true
            end,
          })
        end,
        desc = "🔀 Сравнить с выбранной веткой (Diffview)",
      },
    },
  },
}
