-- ── Python: отладчик, тесты, REPL ────────────────────────────────────────────
-- Extras lang.python / dap.core / test.core — в lazyvim.json
-- <leader>d*  отладка | <leader>t* тесты | <leader>r* REPL | <leader>pr запуск

-- Порядок поиска интерпретатора. Проверяем корень проекта и cwd, потому что
-- venv-ы в проектах называются и .venv, и venv, а uv и conda кладут их по-своему.
local function resolve_python()
  local candidates = {}

  local active = vim.env.VIRTUAL_ENV
  if active and active ~= "" then
    table.insert(candidates, active .. "/bin/python")
  end

  for _, root in ipairs({ LazyVim.root(), vim.fn.getcwd() }) do
    table.insert(candidates, root .. "/.venv/bin/python")
    table.insert(candidates, root .. "/venv/bin/python")
    table.insert(candidates, root .. "/env/bin/python")
  end

  for _, path in ipairs(candidates) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  local conda = vim.fn.getenv("CONDA_PREFIX")
  if conda and conda ~= vim.NIL and conda ~= "" then
    local conda_python = conda .. "/bin/python"
    if vim.fn.executable(conda_python) == 1 then
      return conda_python
    end
  end
  local exepath = vim.fn.exepath("python3")
  return exepath ~= "" and exepath or "python3"
end

return {
  -- ── Venv-selector: выбор окружения из любого буфера ─────────────────────────
  -- LazyVim вешает <leader>cv только на ft=python, поэтому в других файлах
  -- хоткей не срабатывал. Дублируем маппинг без ft.
  -- Про uv: плагин умеет PEP-723 скрипты (# /// script → uv sync --script);
  -- в обычном uv-проекте (uv.lock + .venv) venv находится как .venv/bin/python.
  {
    "linux-cultist/venv-selector.nvim",
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "🐍 Выбрать Python venv" },
    },
  },

  -- ── Ruff: автофикс и импорты ────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    keys = {
      {
        "<leader>pf",
        function()
          -- Ruff: исправить все auto-fixable проблемы
          vim.lsp.buf.code_action({
            context = {
              only = { "source.fixAll.ruff", "source.fixAll" },
              diagnostics = {},
            },
            apply = true,
          })
        end,
        ft = "python",
        desc = "🔧 Ruff: исправить всё (fixAll)",
      },
      {
        "<leader>pi",
        function()
          vim.lsp.buf.code_action({
            context = {
              only = { "source.organizeImports.ruff", "source.organizeImports" },
              diagnostics = {},
            },
            apply = true,
          })
        end,
        ft = "python",
        desc = "📦 Ruff: упорядочить импорты",
      },
      {
        "<leader>pF",
        function()
          -- Форматирование через Ruff (conform / LSP)
          local ok = pcall(function()
            require("conform").format({
              async = true,
              lsp_format = "fallback",
              formatters = { "ruff_format", "ruff_organize_imports", "ruff_fix" },
            })
          end)
          if not ok then
            vim.lsp.buf.format({
              async = true,
              filter = function(client)
                return client.name == "ruff" or client.name == "ruff_lsp"
              end,
            })
          end
        end,
        ft = "python",
        desc = "🎨 Ruff: форматировать файл",
      },
      {
        "<leader>px",
        function()
          -- Запуск ruff check --fix на текущем файле (CLI fallback)
          local file = vim.fn.expand("%:p")
          vim.cmd("w")
          local ruff = vim.fn.exepath("ruff")
          if ruff == "" then
            ruff = vim.fn.stdpath("data") .. "/mason/bin/ruff"
          end
          if vim.fn.executable(ruff) == 0 then
            vim.notify("ruff не найден (установите через :Mason)", vim.log.levels.ERROR)
            return
          end
          local out = vim.fn.system({ ruff, "check", "--fix", file })
          vim.cmd("checktime")
          if vim.v.shell_error == 0 then
            vim.notify("✅ Ruff fix: готово", vim.log.levels.INFO)
          else
            vim.notify(out ~= "" and out or "Ruff: есть неисправленные замечания", vim.log.levels.WARN)
          end
        end,
        ft = "python",
        desc = "🔧 Ruff CLI: check --fix",
      },
    },
  },

  -- ── DAP: русские хоткеи + конфиги запуска ──────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "🔴 Breakpoint" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Условие: "))
        end,
        desc = "🔴 Условный breakpoint",
      },
      { "<leader>dc", function() require("dap").continue() end, desc = "▶  Продолжить / Запустить" },
      { "<leader>ds", function() require("dap").step_into() end, desc = "⬇  Шаг в функцию" },
      { "<leader>dn", function() require("dap").step_over() end, desc = "➡  Следующий шаг" },
      { "<leader>do", function() require("dap").step_out() end, desc = "⬆  Шаг из функции" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "⏹  Остановить отладку" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "🖥  UI отладчика" },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        mode = { "n", "v" },
        desc = "🔍 Вычислить выражение",
      },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "↪  Выполнить до курсора" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "↩  Повторить последний запуск" },
      {
        "<leader>dp",
        function()
          require("dap-python").test_method()
        end,
        desc = "🐛 Отладить метод",
      },
    },
    opts = function()
      -- Доп. launch-конфиги после загрузки dap-python (LazyVim python extra)
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          local ok, dap = pcall(require, "dap")
          if not ok then
            return
          end
          dap.configurations.python = dap.configurations.python or {}

          local function has_name(name)
            for _, cfg in ipairs(dap.configurations.python) do
              if cfg.name == name then
                return true
              end
            end
            return false
          end

          if not has_name("🐍 Текущий файл") then
            table.insert(dap.configurations.python, {
              type = "python",
              request = "launch",
              name = "🐍 Текущий файл",
              program = "${file}",
              console = "integratedTerminal",
              justMyCode = false,
              cwd = "${workspaceFolder}",
              pythonPath = resolve_python,
            })
          end

          if not has_name("🐍 Текущий файл (с аргументами)") then
            table.insert(dap.configurations.python, {
              type = "python",
              request = "launch",
              name = "🐍 Текущий файл (с аргументами)",
              program = "${file}",
              console = "integratedTerminal",
              justMyCode = false,
              cwd = "${workspaceFolder}",
              args = function()
                local input = vim.fn.input("Аргументы: ")
                return vim.split(input, " ", { trimempty = true })
              end,
              pythonPath = resolve_python,
            })
          end

          if not has_name("🐍 Модуль (python -m)") then
            table.insert(dap.configurations.python, {
              type = "python",
              request = "launch",
              name = "🐍 Модуль (python -m)",
              module = function()
                return vim.fn.input("Модуль: ")
              end,
              console = "integratedTerminal",
              justMyCode = false,
              cwd = "${workspaceFolder}",
              pythonPath = resolve_python,
            })
          end

          -- Знаки breakpoints
          vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint" })
          vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DapBreakpointCondition" })
          vim.fn.sign_define("DapStopped", { text = "▶ ", texthl = "DapStopped", linehl = "DapStoppedLine" })
        end,
      })
    end,
  },

  -- Убедиться, что dap-python использует рабочий python (строка, не функция)
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      local adapter = vim.fn.executable(mason_debugpy) == 1 and mason_debugpy or resolve_python()
      require("dap-python").setup(adapter)
    end,
  },

  -- ── Тесты ──────────────────────────────────────────────────────────────────
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-python" },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "🧪 Запустить тест" },
      {
        "<leader>tT",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "🧪 Все тесты в файле",
      },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "📋 Сводка тестов" },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "📄 Вывод теста",
      },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "📄 Панель вывода" },
      {
        "<leader>td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "🐛 Отладить тест",
      },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "⏹  Остановить тест" },
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          dap = { justMyCode = false },
          runner = "pytest",
          python = resolve_python,
          -- -s: не перехватывать stdout — print() в тестах и коде видны
          -- сразу в выводе теста (Space to), без секции "Captured stdout"
          args = { "-s" },
        },
      },
      -- После КАЖДОГО завершения запуска теста открывать окно вывода —
      -- как Test Runner в PyCharm. Дефолтный open_on_run показывает вывод
      -- только для упавших тестов. Окно открывается без перехвата фокуса.
      consumers = {
        auto_output = function(client)
          local pending = {} -- id позиций текущего запуска -> true
          client.listeners.run = function(_, root_id)
            pending[root_id] = true
          end
          client.listeners.results = function(_, results, partial)
            -- partial = потоковые обновления по ходу теста, ждём финал
            if partial then
              return
            end
            for id in pairs(results) do
              if pending[id] then
                vim.schedule(function()
                  require("neotest").output.open({
                    position_id = id,
                    enter = false, -- фокус остаётся в коде
                    short = false, -- полный вывод, вместе с print()
                    auto_close = true,
                    quiet = true,
                  })
                end)
                break
              end
            end
          end
        end,
      },
    },
  },

  -- ── Python REPL — префикс <leader>r ────────────────────────────────────────
  {
    "Vigemus/iron.nvim",
    keys = {
      { "<leader>ri", "<cmd>IronRepl<cr>", desc = "🐍 Открыть Python REPL" },
      { "<leader>rr", "<cmd>IronRestart<cr>", desc = "🔄 Перезапустить REPL" },
      { "<leader>rh", "<cmd>IronHide<cr>", desc = "👁  Скрыть REPL" },
      { "<leader>rf", "<cmd>IronFocus<cr>", desc = "📌 Фокус на REPL" },
      {
        "<leader>rs",
        function()
          require("iron.core").send_line()
        end,
        desc = "📤 Отправить строку в REPL",
      },
      {
        "<leader>rs",
        function()
          require("iron.core").visual_send()
        end,
        mode = "v",
        desc = "📤 Отправить выделение в REPL",
      },
      {
        "<leader>rF",
        function()
          require("iron.core").send_file()
        end,
        desc = "📤 Отправить файл в REPL",
      },
    },
    config = function()
      local view = require("iron.view")
      require("iron.core").setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = function()
                local venv_ipython = vim.fn.getcwd() .. "/.venv/bin/ipython"
                if vim.fn.executable(venv_ipython) == 1 then
                  return { venv_ipython, "--no-autoindent" }
                end
                if vim.fn.executable("ipython") == 1 then
                  return { "ipython", "--no-autoindent" }
                end
                local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
                if vim.fn.executable(venv_python) == 1 then
                  return { venv_python }
                end
                return { "python3" }
              end,
            },
          },
          repl_open_cmd = view.split.horizontal.botright(15),
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },
}
