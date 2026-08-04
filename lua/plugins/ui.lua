-- ── UI улучшения ──────────────────────────────────────────────────────────────
-- Структура кода, навигация, zen mode, цвета, отступы

return {
  -- ── Файловый менеджер (расширяем neo-tree из LazyVim) ─────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      sources = { "filesystem", "buffers", "git_status" },
      source_selector = {
        winbar = true,
        content_layout = "center",
        sources = {
          { source = "filesystem",  display_name = "  Файлы" },
          { source = "buffers",     display_name = "  Буферы" },
          { source = "git_status",  display_name = "  Git" },
        },
      },
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
        },
        modified = { symbol = "●" },
        git_status = {
          symbols = {
            added     = "✚",
            modified  = "",
            deleted   = "✖",
            renamed   = "󰁕",
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          },
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,      -- Показывать скрытые файлы
          hide_gitignored = false,    -- Показывать .gitignored файлы
          hide_hidden = false,
          never_show = { ".DS_Store", "thumbs.db" },
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        group_empty_dirs = false,
        use_libuv_file_watcher = true, -- Авто-обновление при изменении FS
      },
      window = {
        position = "left",
        width = 35,
        mappings = {
          ["<space>"] = "none",
          -- Переключение вкладок: Файлы / Буферы / Git
          ["<"] = "prev_source",
          [">"] = "next_source",
          ["1"] = function()
            require("neo-tree.command").execute({ source = "filesystem", reveal = true })
          end,
          ["2"] = function()
            require("neo-tree.command").execute({ source = "buffers" })
          end,
          ["3"] = function()
            require("neo-tree.command").execute({ source = "git_status" })
          end,
          -- Скопировать путь к файлу
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
              vim.notify("📋 Скопировано: " .. path, vim.log.levels.INFO)
            end,
            desc = "Скопировать путь",
          },
        },
      },
    },
    keys = {
      {
        "<leader>ef",
        function()
          require("neo-tree.command").execute({ toggle = true, source = "filesystem", reveal = true })
        end,
        desc = "📁 Neo-tree: Файлы",
      },
      {
        "<leader>eb",
        function()
          require("neo-tree.command").execute({ toggle = true, source = "buffers" })
        end,
        desc = "📄 Neo-tree: Буферы",
      },
      {
        "<leader>eg",
        function()
          require("neo-tree.command").execute({ toggle = true, source = "git_status" })
        end,
        desc = "🌿 Neo-tree: Git",
      },
    },
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
          "help", "alpha", "dashboard", "neo-tree",
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
        neogit = true,
        noice = true,
        notify = true,
        nvim_surround = true,
        outline = true,
        telescope = { enabled = true },
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
