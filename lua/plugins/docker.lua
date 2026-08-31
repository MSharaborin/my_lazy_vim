-- ── Docker + терминал ────────────────────────────────────────────────────────
-- Префикс <leader>k — контейнеры (не пересекается с отладкой <leader>d)
-- Префикс <leader>T — терминал
-- <C-\> — быстрый плавающий терминал

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm direction=float<cr>", desc = "📟 Плавающий терминал", mode = { "n", "t", "i" } },
      { "<leader>Tf", "<cmd>ToggleTerm direction=float<cr>", desc = "📟 Терминал (плавающий)" },
      { "<leader>Th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "📟 Терминал (снизу)" },
      { "<leader>Tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "📟 Терминал (сбоку)" },
    },
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.4)
          end
          return 20
        end,
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
        float_opts = {
          border = "curved",
          width = function()
            return math.floor(vim.o.columns * 0.85)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.80)
          end,
          winblend = 3,
        },
        highlights = {
          FloatBorder = { link = "FloatBorder" },
        },
        on_create = function(term)
          vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = term.bufnr, desc = "Выйти в normal mode" })
          vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { buffer = term.bufnr })
          vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { buffer = term.bufnr })
          vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { buffer = term.bufnr })
          vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { buffer = term.bufnr })
        end,
      })

      local Terminal = require("toggleterm.terminal").Terminal

      local function get_python()
        local venv = vim.fn.getcwd() .. "/.venv/bin/python"
        if vim.fn.executable(venv) == 1 then
          return venv
        end
        local conda = vim.fn.getenv("CONDA_PREFIX")
        if conda and conda ~= vim.NIL and conda ~= "" then
          local conda_python = conda .. "/bin/python"
          if vim.fn.executable(conda_python) == 1 then
            return conda_python
          end
        end
        return "python3"
      end

      local function list_containers()
        local handle = io.popen("docker ps --format '{{.Names}}' 2>/dev/null")
        if not handle then
          return nil
        end
        local containers_str = handle:read("*a")
        handle:close()
        local containers = {}
        for name in containers_str:gmatch("[^\n]+") do
          if name ~= "" then
            table.insert(containers, name)
          end
        end
        return containers
      end

      vim.keymap.set("n", "<leader>kk", function()
        local candidates = {
          "lazydocker",
          vim.fn.expand("~/.local/bin/lazydocker"),
          vim.fn.expand("~/.config/nvim/bin/lazydocker"),
          vim.fn.expand("~/go/bin/lazydocker"),
        }
        local bin = nil
        for _, c in ipairs(candidates) do
          if vim.fn.executable(c) == 1 then
            bin = c
            break
          end
        end
        if not bin then
          vim.notify(
            "lazydocker не найден!\nУстановите:\n  brew install lazydocker\nили:\n  # бинарник в ~/.local/bin",
            vim.log.levels.ERROR,
            { title = "Docker" }
          )
          return
        end
        Terminal:new({
          cmd = bin,
          dir = "git_dir",
          direction = "float",
          float_opts = {
            border = "double",
            width = function()
              return math.floor(vim.o.columns * 0.95)
            end,
            height = function()
              return math.floor(vim.o.lines * 0.90)
            end,
          },
          on_open = function(term)
            vim.cmd("startinsert!")
            vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
          end,
        }):toggle()
      end, { desc = "🐳 Lazydocker" })

      -- ── Docker exec ────────────────────────────────────────────────────────
      vim.keymap.set("n", "<leader>ke", function()
        local containers = list_containers()
        if not containers then
          vim.notify("Docker недоступен", vim.log.levels.ERROR)
          return
        end
        if #containers == 0 then
          vim.notify("Нет запущенных контейнеров", vim.log.levels.WARN, { title = "Docker" })
          return
        end

        vim.ui.select(containers, {
          prompt = "Выберите контейнер:",
          format_item = function(item)
            return "🐳 " .. item
          end,
        }, function(choice)
          if choice then
            local shell_cmd = "docker exec -it "
              .. choice
              .. " bash 2>/dev/null || docker exec -it "
              .. choice
              .. " sh"
            Terminal:new({
              cmd = shell_cmd,
              direction = "float",
              float_opts = {
                border = "curved",
                width = function()
                  return math.floor(vim.o.columns * 0.85)
                end,
                height = function()
                  return math.floor(vim.o.lines * 0.80)
                end,
              },
              on_open = function(_)
                vim.cmd("startinsert!")
              end,
              close_on_exit = false,
            }):toggle()
          end
        end)
      end, { desc = "🐳 Войти в контейнер" })

      -- ── Docker logs ────────────────────────────────────────────────────────
      vim.keymap.set("n", "<leader>kl", function()
        local containers = list_containers()
        if not containers or #containers == 0 then
          vim.notify("Нет запущенных контейнеров", vim.log.levels.WARN)
          return
        end

        vim.ui.select(containers, {
          prompt = "Логи контейнера:",
          format_item = function(item)
            return "📋 " .. item
          end,
        }, function(choice)
          if choice then
            Terminal:new({
              cmd = "docker logs -f " .. choice,
              direction = "horizontal",
              close_on_exit = false,
            }):toggle()
          end
        end)
      end, { desc = "📋 Логи Docker контейнера" })

      -- ── Запуск Python файла ─────────────────────────────────────────────────
      vim.keymap.set("n", "<leader>pr", function()
        if vim.bo.filetype ~= "python" then
          vim.notify("Не Python файл", vim.log.levels.WARN)
          return
        end
        vim.cmd("w")
        local file = vim.fn.expand("%:p")
        local python = get_python()
        Terminal:new({
          cmd = python .. " " .. vim.fn.shellescape(file),
          direction = "horizontal",
          close_on_exit = false,
          on_open = function(_)
            vim.cmd("startinsert!")
          end,
        }):toggle()
      end, { desc = "🚀 Запустить Python файл" })

      -- Запуск с аргументами
      vim.keymap.set("n", "<leader>pR", function()
        if vim.bo.filetype ~= "python" then
          vim.notify("Не Python файл", vim.log.levels.WARN)
          return
        end
        vim.cmd("w")
        local file = vim.fn.expand("%:p")
        local python = get_python()
        vim.ui.input({ prompt = "Аргументы: " }, function(args)
          if args == nil then
            return
          end
          local cmd = python .. " " .. vim.fn.shellescape(file)
          if args ~= "" then
            cmd = cmd .. " " .. args
          end
          Terminal:new({
            cmd = cmd,
            direction = "horizontal",
            close_on_exit = false,
            on_open = function(_)
              vim.cmd("startinsert!")
            end,
          }):toggle()
        end)
      end, { desc = "🚀 Python файл с аргументами" })

      -- ── Docker compose ─────────────────────────────────────────────────────
      vim.keymap.set("n", "<leader>ku", function()
        Terminal:new({
          cmd = "docker compose up",
          direction = "horizontal",
          close_on_exit = false,
        }):toggle()
      end, { desc = "🐳 docker compose up" })

      vim.keymap.set("n", "<leader>kd", function()
        Terminal:new({
          cmd = "docker compose down",
          direction = "horizontal",
          close_on_exit = false,
        }):toggle()
      end, { desc = "🐳 docker compose down" })

      vim.keymap.set("n", "<leader>kb", function()
        Terminal:new({
          cmd = "docker compose up --build",
          direction = "horizontal",
          close_on_exit = false,
        }):toggle()
      end, { desc = "🐳 docker compose up --build" })

      vim.keymap.set("n", "<leader>kp", function()
        Terminal:new({
          cmd = "docker ps",
          direction = "float",
          close_on_exit = false,
        }):toggle()
      end, { desc = "🐳 docker ps" })

      -- ── Docker compose: управление из файла docker-compose.yml ─────────────
      -- При открытии docker-compose.yml работают (буферные, перекрывают глобальные):
      --   <leader>ku — запустить сервис под курсором или выбрать из списка
      --   <leader>kb — запустить ВСЕ сервисы с пересборкой (up --build)
      --   <leader>kd — остановить (down)

      local function compose_services()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local services, in_services = {}, false
        for _, line in ipairs(lines) do
          local indent, body = line:match("^(%s*)(.-)%s*$")
          if body:match("^services:%s*[#]?.*$") then
            in_services = true
          elseif in_services then
            if body == "" or indent == "" then
              in_services = false
            else
              local svc = body:match("^([%w._%-]+):%s*$")
              if svc then
                table.insert(services, svc)
              end
            end
          end
        end
        return services
      end

      local function service_under_cursor()
        local line = vim.fn.getline(".")
        return line:match("^%s*([%w._%-]+):%s*$")
      end

      local function compose_term(cmd_suffix)
        local compose_file = vim.fn.expand("%:p")
        local cmd = "docker compose -f " .. vim.fn.shellescape(compose_file) .. " " .. cmd_suffix
        Terminal:new({
          cmd = cmd,
          direction = "horizontal",
          close_on_exit = false,
        }):toggle()
      end

      local function compose_up()
        local svc = service_under_cursor()
        if svc then
          compose_term("up " .. svc)
          return
        end
        local services = compose_services()
        table.insert(services, 1, "@все сервисы (up)")
        vim.ui.select(services, {
          prompt = "Docker compose:",
          format_item = function(item)
            return "🐳 " .. item
          end,
        }, function(choice)
          if not choice then
            return
          end
          if choice == "@все сервисы (up)" then
            compose_term("up")
          else
            compose_term("up " .. choice)
          end
        end)
      end

      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("ComposeKeys", { clear = true }),
        pattern = {
          "docker-compose.yml",
          "docker-compose.yaml",
          "docker-compose*.yml",
          "docker-compose*.yaml",
          "compose.yml",
          "compose.yaml",
        },
        callback = function(event)
          local opts = { buffer = event.buf, silent = true }
          vim.keymap.set(
            "n",
            "<leader>ku",
            compose_up,
            vim.tbl_extend("force", opts, { desc = "🐳 Compose: up сервис под курсором / выбрать" })
          )
          vim.keymap.set(
            "n",
            "<leader>kb",
            function()
              compose_term("up --build")
            end,
            vim.tbl_extend("force", opts, { desc = "🐳 Compose: up --build (все сервисы)" })
          )
          vim.keymap.set(
            "n",
            "<leader>kd",
            function()
              compose_term("down")
            end,
            vim.tbl_extend("force", opts, { desc = "🐳 Compose: down" })
          )
        end,
      })
    end,
  },
}
