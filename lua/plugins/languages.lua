-- ── Мультиязычная поддержка: Rust, Go, C++, JavaScript/React ─────────────────
-- Extras также перечислены в lazyvim.json (единый источник через LazyExtras)
-- Здесь: доп. плагины и хоткеи без повторного import extras (чтобы не дублировать)

return {
  -- ── Rust (<leader>R*) ──────────────────────────────────────────────────────
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    keys = {
      { "<leader>Re", function() vim.cmd.RustLsp("expandMacro") end, ft = "rust", desc = "🦀 Раскрыть макрос" },
      { "<leader>Rc", function() vim.cmd.RustLsp("openCargo") end, ft = "rust", desc = "🦀 Открыть Cargo.toml" },
      { "<leader>Rr", function() vim.cmd.RustLsp("runnables") end, ft = "rust", desc = "🦀 Запустить (Rust)" },
      { "<leader>Rd", function() vim.cmd.RustLsp("debuggables") end, ft = "rust", desc = "🦀 Отладить (Rust)" },
      { "<leader>Rt", function() vim.cmd.RustLsp("testables") end, ft = "rust", desc = "🦀 Тесты (Rust)" },
      { "<leader>Rm", function() vim.cmd.RustLsp("parentModule") end, ft = "rust", desc = "🦀 Родительский модуль" },
      { "<leader>Rj", function() vim.cmd.RustLsp("joinLines") end, ft = "rust", desc = "🦀 Объединить строки" },
      { "<leader>RI", function() vim.cmd.RustLsp("hover", "actions") end, ft = "rust", desc = "🦀 Hover actions" },
    },
  },

  -- ── Go (<leader>G*) ────────────────────────────────────────────────────────
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()',
    cmd = { "GoInit" },
    keys = {
      { "<leader>Gr", "<cmd>GoRun %<cr>", ft = "go", desc = "🐹 Запустить (Go)" },
      { "<leader>Gt", "<cmd>GoTest<cr>", ft = "go", desc = "🐹 Тесты (Go)" },
      { "<leader>Gf", "<cmd>GoFmt<cr>", ft = "go", desc = "🐹 Форматировать (Go)" },
      { "<leader>Gi", "<cmd>GoImport<cr>", ft = "go", desc = "🐹 Импорты (Go)" },
      { "<leader>Ga", "<cmd>GoAddTag<cr>", ft = "go", desc = "🐹 Добавить тег (Go)" },
      { "<leader>Gl", "<cmd>GoLint<cr>", ft = "go", desc = "🐹 Линтер (Go)" },
      { "<leader>Gc", "<cmd>GoCoverage<cr>", ft = "go", desc = "🐹 Покрытие тестами (Go)" },
      { "<leader>Ge", "<cmd>GoIfErr<cr>", ft = "go", desc = "🐹 Добавить if err (Go)" },
    },
    config = function()
      require("go").setup({
        goimports = "gopls",
        gofmt = "gopls",
        lsp_cfg = false,
        lsp_gofumpt = true,
        lsp_on_attach = false,
        dap_debug = true,
      })

      vim.api.nvim_create_user_command("GoInit", function(opts)
        local name = opts.fargs[1] or vim.fn.input("Название проекта: ")
        name = vim.trim(name or "")
        if name == "" then
          return vim.notify("Имя проекта не указано", vim.log.levels.ERROR)
        end

        if vim.fn.exepath("go") == "" then
          return vim.notify("go не найден — установите Go", vim.log.levels.ERROR)
        end

        local dir = vim.fn.getcwd() .. "/" .. name
        if vim.fn.isdirectory(dir) == 1 then
          return vim.notify("Директория уже существует: " .. dir, vim.log.levels.WARN)
        end

        vim.fn.mkdir(dir, "p")
        local res = vim.system({ "go", "mod", "init", name }, { cwd = dir, text = true }):wait()
        if res.code ~= 0 then
          return vim.notify("go mod init: " .. res.stderr, vim.log.levels.ERROR)
        end

        vim.fn.writefile(vim.split([[
package main

import "fmt"

func main() {
	fmt.Println("Hello from __NAME__")
}
]], "\n"), dir .. "/main.go")

        vim.cmd("cd " .. vim.fn.fnameescape(dir))
        vim.cmd("edit main.go")
        vim.notify("✅ Go-проект создан: " .. dir, vim.log.levels.INFO)
      end, { nargs = "?", desc = "Создать Go-проект: папка + go.mod + main.go" })
    end,
  },

  -- ── JSX/TSX autotag ────────────────────────────────────────────────────────
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "jsx", "typescript", "tsx", "vue", "svelte" },
    opts = {},
  },

  -- ── Treesitter ─────────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c",
        "cpp",
        "go",
        "gomod",
        "gowork",
        "gotmpl",
        "rust",
        "toml",
        "javascript",
        "typescript",
        "tsx",
        "jsx",
        "python",
        "html",
        "css",
        "sql",
        "json",
        "yaml",
        "dockerfile",
        "bash",
        "make",
        "markdown",
        "markdown_inline",
        "rst",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "regex",
        "diff",
        "git_config",
        "git_rebase",
        "gitcommit",
      })
      opts.highlight = opts.highlight or { enable = true }
      opts.indent = opts.indent or { enable = true }
      opts.incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<C-s>",
          node_decremental = "<bs>",
        },
      }
    end,
  },

  -- ── Mason: LSP / DAP / линтеры ─────────────────────────────────────────────
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright",
        "ruff",
        "debugpy",
        "gopls",
        "goimports",
        "golines",
        "golangci-lint",
        "clangd",
        "clang-format",
        "codelldb",
        "typescript-language-server",
        "prettier",
        "eslint-lsp",
        "html-lsp",
        "css-lsp",
        "emmet-language-server",
        "sqlls",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "yaml-language-server",
        "json-lsp",
        "jsonlint",
        "bash-language-server",
        "shellcheck",
        "shfmt",
        "stylua",
        "markdownlint",
      })
      return opts
    end,
  },
}
