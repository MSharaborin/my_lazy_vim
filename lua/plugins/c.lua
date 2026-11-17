-- ── C / C++: сборка (gcc) и запуск в терминале ────────────────────────────────
-- Префикс <leader>C — компиляция, запуск, отладка lldb
--   Space Cb — только билд        Space CR — билд + запуск
--   Space Cd — отладка lldb        Space Cq — билд в quickfix
--   Space Cl — закрыть терминал
-- Экстра lang.clangd подключён в lazyvim.json, gcc/g++/lldb — системные.
-- Компилятор выбирается по filetype: c → gcc, cpp/objc/objcpp → g++.
-- Бинарь собирается рядом с исходником: <каталог>/<имя_файла>

local Terminal

local FT_ALL = { "c", "cpp", "objc", "objcpp" }

local FLAGS = { "-g", "-Wall", "-Wextra" }

local HEADER_EXT = { h = true, hpp = true, hh = true, hxx = true, inc = true, inl = true }

local cache = {}

--- Контекст текущего файла: исходник, имя бинаря, директория, компилятор.
---@return table|nil
local function context()
  if vim.bo.buftype ~= "" then
    vim.notify(
      "Это не обычный файл — нечего собирать",
      vim.log.levels.WARN,
      { title = "C/C++" }
    )
    return nil
  end

  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("Нет файла — нечего собирать", vim.log.levels.WARN, { title = "C/C++" })
    return nil
  end

  local name = vim.fn.fnamemodify(file, ":t")
  if HEADER_EXT[vim.fn.fnamemodify(name, ":e")] then
    vim.notify(
      name .. " — заголовок. Откройте .c / .cpp, чтобы собрать бинарь",
      vim.log.levels.WARN,
      { title = "C/C++" }
    )
    return nil
  end

  local base = vim.fn.fnamemodify(name, ":t:r")
  local dir = vim.fn.fnamemodify(file, ":h")

  return {
    file = file,
    base = base,
    dir = dir,
    compiler = vim.bo.filetype == "c" and "gcc" or "g++",
    bin = dir .. "/" .. base,
  }
end

---@param ctx table
---@return string[]
local function build_argv(ctx)
  local argv = { ctx.compiler }
  vim.list_extend(argv, FLAGS)
  vim.list_extend(argv, { ctx.file, "-o", ctx.bin })
  return argv
end

--- Строка команды для терминала: пути экранируются.
---@param ctx table
---@return string
local function build_shell(ctx)
  local argv = build_argv(ctx)
  for i, a in ipairs(argv) do
    argv[i] = vim.fn.shellescape(a)
  end
  return table.concat(argv, " ")
end

--- Терминал с данным именем: пересоздаём, чтобы прошлая сессия (lldb) не мешала.
--- close_on_exit = false — вывод программы остаётся в окне, пока не нажмёшь Space Cl.
local function open_terminal(name, cmd, dir)
  if not Terminal then
    Terminal = require("toggleterm.terminal").Terminal
  end

  local term = cache[name]
  if term then
    term:shutdown()
    cache[name] = nil
  end

  term = Terminal:new({
    cmd = cmd,
    dir = dir,
    direction = "float",
    close_on_exit = false,
    on_open = function()
      vim.cmd("startinsert!")
    end,
  })

  cache[name] = term
  term:toggle()
end

---@param msg string
local function notify_ok(msg)
  vim.notify("✅ " .. msg, vim.log.levels.INFO, { title = title })
end

---@param msg string
local function notify_err(msg)
  vim.notify("❌ " .. msg, vim.log.levels.ERROR, { title = "C/C++" })
end

--- Space Cb — только собрать
local function build()
  local ctx = context()
  if not ctx then
    return
  end
  if vim.fn.executable(ctx.compiler) == 0 then
    return notify_err(ctx.compiler .. " не найден")
  end
  vim.cmd("w")
  open_terminal("c_build", build_shell(ctx), ctx.dir)
  notify_ok("Сборка: " .. ctx.compiler .. " " .. ctx.base)
end

--- Space CR — собрать и сразу запустить
local function build_and_run()
  local ctx = context()
  if not ctx then
    return
  end
  if vim.fn.executable(ctx.compiler) == 0 then
    return notify_err(ctx.compiler .. " не найден")
  end
  vim.cmd("w")
  open_terminal("c_run", build_shell(ctx) .. " && ./" .. vim.fn.shellescape(ctx.base), ctx.dir)
  notify_ok(ctx.compiler .. " → " .. ctx.base)
end

--- Space Cd — lldb в том же флоате
local function debug_lldb()
  local ctx = context()
  if not ctx then
    return
  end
  if vim.fn.executable(ctx.bin) == 0 then
    return notify_err("Бинарь не найден: " .. ctx.base .. " — сначала Space CR")
  end
  if vim.fn.exepath("lldb") == "" then
    return notify_err("lldb не найден (xcode-select --install)")
  end
  open_terminal("c_debug", "lldb " .. vim.fn.shellescape(ctx.bin), ctx.dir)
end

--- Space Cl — закрыть терминалы сборки/запуска/отладки
local function close_terminals()
  if not Terminal then
    Terminal = require("toggleterm.terminal").Terminal
  end
  local closed = 0
  for _, term in pairs(cache) do
    term:shutdown()
    closed = closed + 1
  end
  cache = {}
  notify_ok(
    closed == 0 and "Терминалы C/C++ не открыты"
      or ("Закрыто терминалов: " .. closed)
  )
end

--- Space Cq — синхронная сборка, ошибки в quickfix (:cnext / ]q)
local function build_quickfix()
  local ctx = context()
  if not ctx then
    return
  end
  if vim.fn.executable(ctx.compiler) == 0 then
    return notify_err(ctx.compiler .. " не найден")
  end
  vim.cmd("w")

  local res = vim.system(build_argv(ctx), { cwd = ctx.dir, text = true }):wait()
  local out = (res.stdout or "") .. (res.stderr or "")

  if res.code == 0 then
    vim.fn.setqflist({}, "f", { title = ctx.compiler, items = {} })
    return notify_ok("Сборка без ошибок: " .. ctx.base)
  end

  local items = {}
  for _, line in ipairs(vim.split(out, "\n", { plain = true })) do
    local file, lnum, col, sev, msg = line:match("^(.-):(%d+):(%d+):%s+(%a+):%s+(.*)$")
    if file then
      local path = vim.fn.fnamemodify(file, ":p")
      table.insert(items, {
        bufnr = vim.fn.bufnr(path) ~= -1 and vim.fn.bufnr(path) or vim.fn.bufadd(path),
        lnum = tonumber(lnum),
        col = tonumber(col),
        type = sev:lower():find("error") and "E" or "W",
        text = msg,
      })
    end
  end

  if #items == 0 then
    vim.notify(out, vim.log.levels.ERROR, { title = "C/C++" })
    return
  end

  vim.fn.setqflist({}, "r", { title = ctx.compiler, items = items })
  vim.cmd("copen")
  notify_err(string.format("Ошибок: %d — список открыт", #items))
end

return {
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<leader>Cb", build, ft = FT_ALL, desc = "🔨 Собрать (gcc)" },
      { "<leader>CR", build_and_run, ft = FT_ALL, desc = "▶ Собрать и запустить" },
      { "<leader>Cd", debug_lldb, ft = FT_ALL, desc = "🐛 Отладка lldb" },
      { "<leader>Cq", build_quickfix, ft = FT_ALL, desc = "📋 Собрать в quickfix" },
      { "<leader>Cl", close_terminals, ft = FT_ALL, desc = "🧹 Закрыть терминалы" },
    },
  },
}
