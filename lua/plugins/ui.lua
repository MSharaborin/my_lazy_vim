-- ── UI улучшения ──────────────────────────────────────────────────────────────
-- Структура кода, навигация, zen mode, цвета, отступы

-- Панель коммита в стиле PyCharm: список изменённых файлов, отметка через Tab,
-- поле сообщения снизу и кнопки Commit (<C-c>) / Push (<C-p>).
-- Сделано на snacks-пикере git_status: у него уже есть поле ввода снизу и
-- экшен git_stage. Neogit в текущей версииcommit открывает popup, а не поле
-- с кнопками, поэтому для этого UX взят snacks.
local function git_run(cmd, on_ok)
  local res = vim.system(cmd, { text = true }):wait()
  if res.code == 0 then
    if on_ok then
      on_ok()
    end
  else
    local msg = (res.stderr or ""):gsub("^fatal:%s*", "")
    if msg == "" then
      msg = (res.stdout or ""):gsub("^fatal:%s*", "")
    end
    vim.notify("❌ " .. msg, vim.log.levels.ERROR, { title = "Git" })
  end
end

-- snacks передаёт в экшен разные вещи: сам picker, элемент списка или объект
-- окна (для неназначенных клавиш — p.input.win). Поэтому аргументу не доверяем
-- и берём активный picker из списка. Признак picker'а — поля input и list.
local function active_picker(candidate)
  if candidate and candidate.input and candidate.list then
    return candidate
  end
  local list = Snacks.picker.get({ tab = false })
  return list and list[#list] or nil
end

return {
  -- ── Snacks: пикеры (Explorer, буферы, панель коммита) + видимость файлов ────
  -- Дефолты snacks: sources.files = { hidden = false, ignored = false }.
  -- Это значит, что fd ищет без --hidden и без --no-ignore, поэтому файлы вроде
  -- .env (точка + .gitignore) не находятся вообще — их нет даже в результатах.
  -- hidden = true → --hidden, ignored = true → --no-ignore.
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>eb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "📄 Буферы",
      },
      {
        "<leader>eg",
        function()
          Snacks.picker.git_status()
        end,
        desc = "🌿 Git: файлы к коммиту (Commit / Push)",
      },
    },
    opts = function(_, opts)
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}

      for _, name in ipairs({ "explorer", "files" }) do
        local src = opts.picker.sources[name] or {}
        src.hidden = true -- показывать .env, .gitignore, .config, .venv
        src.ignored = true -- показывать файлы из .gitignore
        src.exclude = { ".git" } -- служебное содержимое .git не показываем
        opts.picker.sources[name] = src
      end

      -- Панель коммита: кнопки к полю ввода и к списку файлов
      local git_status = opts.picker.sources.git_status or {}
      local win = git_status.win or {}

      local function commit_key()
        return {
          function(p)
            local picker = active_picker(p)
            if not picker then
              return
            end
            local msg = picker.input:get()
            if not msg or msg:match("^%s*$") then
              vim.notify("Введите сообщение коммита", vim.log.levels.WARN, { title = "Git" })
              return
            end
            git_run({ "git", "commit", "-m", msg }, function()
              picker:close()
              vim.notify("✅ " .. msg, vim.log.levels.INFO, { title = "Git" })
            end)
          end,
          mode = { "n", "i" },
        }
      end

      local function push_key()
        return {
          function(p)
            local picker = active_picker(p)
            git_run({ "git", "push" }, function()
              vim.notify("✅ Запушено", vim.log.levels.INFO, { title = "Git" })
              if picker then
                picker:refresh()
              end
            end)
          end,
          mode = { "n", "i" },
          nowait = true,
        }
      end

      local function stage_all_key()
        return {
          function(p)
            local picker = active_picker(p)
            git_run({ "git", "add", "-A" }, function()
              vim.notify("✅ Все файлы отмечены", vim.log.levels.INFO, { title = "Git" })
              if picker then
                picker:refresh()
              end
            end)
          end,
          mode = { "n", "i" },
          nowait = true,
        }
      end

      -- Клавиши вешаем и в поле ввода, и в список: фокус может быть на любом,
      -- а коммит должен работать сразу после отметки файлов в списке.
      -- Дефолты snacks (Tab = git_stage, C-r = git_restore) задаём сами: на момент
      -- вызова этой функции дефолты ещё не смержены, иначе они бы пропали.
      local base = {
        ["<Tab>"] = { "git_stage", mode = { "n", "i" } }, -- отметить / снять отметку
        ["<c-r>"] = { "git_restore", mode = { "n", "i" }, nowait = true }, -- откатить файл
        ["<c-c>"] = commit_key(),
        ["<c-p>"] = push_key(),
        ["<c-a>"] = stage_all_key(),
      }

      local input = vim.deepcopy(win.input or {})
      local list = vim.deepcopy(win.list or {})
      input.keys = vim.tbl_extend("force", input.keys or {}, base)
      input.prompt = "Commit message: "
      list.keys = vim.tbl_extend("force", list.keys or {}, base)
      win.input = input
      win.list = list
      git_status.win = win
      git_status.confirm = "git_stage" -- Enter тоже отмечает файл
      opts.picker.sources.git_status = git_status

      return opts
    end,
  },

  -- ── Outline — структура кода (классы, функции, переменные) ───────────────
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>cs", "<cmd>Outline<cr>",     desc = "🗂  Структура кода" },
      { "<leader>cS", "<cmd>OutlineOpen<cr>", desc = "🗂  Открыть структуру" },
    },
    opts = {
      outline_window = {
        position = "right",
        width = 30,
        relative_width = false,
        auto_close = false,
        auto_jump = false,
        show_numbers = false,
        show_relative_numbers = false,
        wrap = false,
      },
      outline_items = {
        show_symbol_details = true,
        show_symbol_lineno = true,
        highlight_hovered_item = true,
        auto_set_cursor = true,
      },
      symbols = {
        -- Показывать все типы символов
        filter = nil,
      },
      keymaps = {
        show_help = "?",
        close = { "<Esc>", "q" },
        goto_location = "<Cr>",
        peek_location = "o",
        goto_and_close = "<S-Cr>",
        restore_location = "<C-g>",
        hover_symbol = "<C-space>",
        toggle_preview = "K",
        rename_symbol = "r",
        code_actions = "a",
        fold = "h",
        fold_toggle = "<Tab>",
        fold_toggle_all = "<S-Tab>",
        unfold = "l",
        fold_all = "W",
        unfold_all = "E",
        fold_reset = "R",
        down_and_jump = "<C-j>",
        up_and_jump = "<C-k>",
      },
    },
  },

  -- ── Zen Mode — фокус на коде без отвлечений ───────────────────────────────
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = {
      { "<leader>uz", "<cmd>ZenMode<cr>", desc = "🎯 Zen Mode (фокус)" },
    },
    opts = {
      window = {
        backdrop = 0.95,
        width = 120,
        height = 1,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
          foldcolumn = "0",
          list = false,
        },
      },
      plugins = {
        options = { enabled = true, ruler = false, showcmd = false },
        twilight = { enabled = true },   -- Затемнить неактивный код
        gitsigns  = { enabled = false },
        tmux      = { enabled = false },
      },
    },
  },

  -- ── Twilight — затемнение неактивного кода (работает с Zen Mode) ──────────
  {
    "folke/twilight.nvim",
    cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
    keys = {
      { "<leader>uT", "<cmd>Twilight<cr>", desc = "🌆 Twilight (затемнение)" },
    },
    opts = {
      dimming = { alpha = 0.25 },
      context = 15,
    },
  },

  -- ── Отступы с линиями ─────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPre",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = {
        enabled = true,
        show_start = true,
        show_end = false,
        injected_languages = false,
        highlight = { "Function", "Label" },
        priority = 500,
      },
      exclude = {
        filetypes = {
          "help", "alpha", "dashboard",
          "Trouble", "trouble", "lazy", "mason",
          "notify", "toggleterm", "lazyterm",
        },
      },
    },
  },

  -- ── Подсветка HEX цветов (#FF0000, rgb(...)) ──────────────────────────────
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        AARRGGBB = false,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = false,
        sass = { enable = false },
        virtualtext = "■",
      },
      buftypes = {},
    },
  },

  -- ── Улучшенная строка состояния (lualine) ─────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Путь к файлу в статусбаре
      opts.sections = opts.sections or {}
      opts.sections.lualine_c = {
        {
          "filename",
          path = 1,              -- Относительный путь
          symbols = {
            modified = " ●",
            readonly = " ",
            unnamed  = " [Без имени]",
          },
        },
      }
      -- Правая часть статусбара
      opts.sections.lualine_x = {
        -- Запись макроса
        {
          function()
            local reg = vim.fn.reg_recording()
            if reg == "" then return "" end
            return "⏺ @" .. reg
          end,
          color = { fg = "#ff9e64" },
        },
        -- LSP статус
        {
          function()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients == 0 then return "No LSP" end
            local names = {}
            for _, c in ipairs(clients) do
              table.insert(names, c.name)
            end
            return "  " .. table.concat(names, ", ")
          end,
          color = { fg = "#98c379" },
        },
        { "encoding" },
        { "fileformat" },
        { "filetype" },
      }
      return opts
    end,
  },

  -- ── Улучшенные уведомления (уже есть noice в LazyVim) ────────────────────
  -- Добавляем nvim-notify для красивых всплывающих уведомлений
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width  = function() return math.floor(vim.o.columns * 0.75) end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
      render = "wrapped-compact",
      stages = "fade_in_slide_out",
      background_colour = "#000000",
    },
  },

  -- ── Smooth прокрутка ──────────────────────────────────────────────────────
  {
    "karb94/neoscroll.nvim",
    event = "BufReadPre",
    opts = {
      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      easing_function = "sine",
    },
  },

  -- ── Цветовая схема (Catppuccin — современная и красивая) ─────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",      -- latte / frappe / macchiato / mocha (тёмная)
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.15,
      },
      integrations = {
        blink_cmp = true,
        bufferline = true,
        cmp = true,
        dashboard = true,
        diffview = true,
        flash = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        mini = { enabled = true },
        native_lsp = {
          enabled = true,
          underlines = {
            errors      = { "undercurl" },
            hints       = { "undercurl" },
            warnings    = { "undercurl" },
            information = { "undercurl" },
          },
        },
        noice = true,
        notify = true,
        nvim_surround = true,
        outline = true,
        treesitter = true,
        which_key = true,
      },
    },
  },

  -- Установить Catppuccin как цветовую схему
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
