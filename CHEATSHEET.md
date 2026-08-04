# 📚 Справка Neovim (Leader = Space)

Открыть в редакторе: **F1** · **Space K** · **Space hk**  
Закрыть справку: **q** · **Esc** · **F1**

В статусбаре слово `python` — это **тип файла**, а не виртуальное окружение.

---

## 📄 Открытые файлы (буферы)

| Клавиши | Действие |
|---------|----------|
| `Tab` | следующий открытый файл |
| `Shift-Tab` | предыдущий открытый файл |
| `Space bb` | переключиться на предыдущий буфер |
| клик по вкладке сверху | открыть этот файл мышью |
| `Shift-h` / `Shift-l` | пред. / след. буфер (LazyVim) |

### Закрыть файл

| Клавиши | Действие |
|---------|----------|
| `Space bd` | закрыть текущий файл (буфер) |
| `Space bo` | закрыть все остальные файлы |
| `Space bD` | закрыть принудительно (без сохранения) |
| `:q` | закрыть текущее окно |
| `:qa` | выйти из Neovim |

### Окна (сплиты)

| Клавиши | Действие |
|---------|----------|
| `Ctrl-h/j/k/l` | окно влево / вниз / вверх / вправо |
| `Ctrl-←/→/↑/↓` | изменить размер окна |
| `Space \|` | вертикальный сплит |
| `Ctrl-s` | сохранить файл |
| `jk` | выйти из режима вставки (Insert → Normal) |

---

## 🐍 Python

### Виртуальное окружение (как Interpreter в PyCharm)

| Клавиши / команда | Действие |
|-------------------|----------|
| `Space cv` | **выбрать venv** (список окружений) |
| `:VenvSelect` | то же самое |
| `:!python3 -c "import sys; print(sys.executable)"` | какой Python сейчас используется |
| `:lua =vim.fn.exepath("python3")` | путь к python из Neovim |

**Как подключить своё окружение:**

1. Создай venv в корне проекта (если ещё нет):
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   # полезно для Neovim:
   pip install ipython debugpy pytest
   ```
2. В Neovim открой `.py` файл → нажми `Space cv`
3. Выбери `.venv` (или conda / другое)
4. Если автодополнение «старое»: `:LspRestart`

По умолчанию ищется `./.venv/bin/python`, иначе системный `python3`.  
Выбор через `Space cv` запоминается для проекта и подключает LSP (pyright/ruff) + отладку.

### Запуск и отладка

| Клавиши | Действие |
|---------|----------|
| `Space pr` | запустить текущий файл |
| `Space pR` | запуск с аргументами |
| `Space db` | breakpoint вкл/выкл |
| `Space dB` | условный breakpoint |
| `Space dc` | старт / Continue отладки |
| `Space dn` | Step Over |
| `Space ds` | Step Into |
| `Space do` | Step Out |
| `Space du` | UI отладчика |
| `Space de` | вычислить выражение |
| `Space dq` | остановить отладку |
| `Space tt` | запустить тест |
| `Space tT` | все тесты в файле |
| `Space td` | отладить тест |
| `Space ri` | Python REPL |
| `Space rs` | отправить строку/выделение в REPL |

### Ruff (линтер / фиксы)

| Клавиши | Действие |
|---------|----------|
| `Space pf` | исправить всё (fixAll) |
| `Space pi` | упорядочить импорты |
| `Space pF` | форматировать |
| `Space px` | `ruff check --fix` через CLI |

---

## 📁 Проводник (Neo-tree)

| Клавиши | Действие |
|---------|----------|
| `Space e` | открыть / закрыть проводник |
| `Space ef` | вкладка **Файлы** |
| `Space eb` | вкладка **Буферы** |
| `Space eg` | вкладка **Git** |

**Внутри neo-tree:**

| Клавиши | Действие |
|---------|----------|
| `<` / `>` | предыдущая / следующая вкладка |
| `1` / `2` / `3` | Файлы / Буферы / Git |
| мышь | клик по вкладке сверху |
| `Enter` | открыть файл |
| `q` | закрыть проводник |

---

## 🌿 Git

| Клавиши | Действие |
|---------|----------|
| `Space gg` | Neogit (панель Git) |
| `Space gd` | Diffview (side-by-side) |
| `Space gm` | Merge UI как в PyCharm |
| `Space gh` | история текущего файла |
| `Space gH` | история репозитория |
| `Space gc` | commit |
| `Space gP` | push |
| `Space gF` | pull |
| `Space gs` | stage hunk (**visual = только выделение**) |
| `Space gr` | reset hunk (**visual = только выделение**) |
| `Space gp` | предпросмотр hunk |
| `Space gb` | blame строки |
| `]h` / `[h` | след. / пред. hunk |

### Merge-конфликты (как в PyCharm)

При конфликте появится уведомление.

1. **Открыть 3-way UI:** `Space mcr` или `Space gm`  
   Слева **OURS** (твоё) | Справа **THEIRS** (чужое) | **RESULT** (итог)

2. **Принять блок целиком** (курсор внутри конфликта):

| Клавиши | Как в PyCharm |
|---------|----------------|
| `Space mco` | Accept Yours (своё) |
| `Space mct` | Accept Theirs (чужое) |
| `Space mcb` | Accept Both |
| `Space mc0` | ничего / удалить |
| `]x` / `[x` | след. / пред. конфликт |
| `Space mcl` | список всех конфликтов |

3. **Взять только кусок кода:**
   - в Diffview выдели строки в RESULT (`v`)
   - `Space co` — взять выделение из OURS  
   - `Space ct` — взять выделение из THEIRS  
   - или правь RESULT руками

4. Сохрани (`Ctrl-s`) → `Space gg` → stage → commit

---

## 🐳 Docker

| Клавиши | Действие |
|---------|----------|
| `Space kk` | Lazydocker (TUI) |
| `Space ke` | войти в контейнер |
| `Space kl` | логи контейнера |
| `Space ku` | `docker compose up` |
| `Space kd` | `docker compose down` |
| `Space kb` | `compose up --build` |
| `Space kp` | `docker ps` |

Нужен CLI: `brew install lazydocker`

---

## 📟 Терминал

| Клавиши | Действие |
|---------|----------|
| `Ctrl-\` | плавающий терминал |
| `Space Tf` | плавающий |
| `Space Th` | снизу |
| `Space Tv` | сбоку |
| `Esc Esc` | в терминале → Normal mode |

---

## 🗄️ Базы данных

| Клавиши | Действие |
|---------|----------|
| `Space Db` | панель DBUI |
| `Space Da` | добавить подключение |
| `Space Dq` | выполнить SQL (в sql-буфере) |

Строки подключения:
- Postgres: `postgresql://user:pass@localhost:5432/db`
- MongoDB: `mongodb://user:pass@localhost:27017/db` (нужен `mongosh`)

---

## 💡 Код / LSP

| Клавиши | Действие |
|---------|----------|
| `gd` | перейти к определению |
| `gr` | ссылки |
| `gi` | реализации |
| `K` | документация (hover) |
| `Space ca` | Code Actions |
| `Space cn` | переименовать |
| `Space cf` | форматировать |
| `Space cs` | структура кода (Outline) |
| `Space cd` | показать ошибку |
| `]d` / `[d` | след. / пред. ошибка |
| `Space ff` | найти файл |
| `Space sg` | поиск по проекту (grep) |
| `Space sk` | поиск по всем хоткеям |
| `Space ?` | which-key (клавиши буфера) |

---

## 🦀 Rust · 🐹 Go

| Rust (`Space R…`) | Go (`Space G…`) |
|-------------------|-----------------|
| `Rr` Runnables | `Gr` Run |
| `Rd` Debuggables | `Gt` Test |
| `Rt` Testables | `Gi` Imports |
| `Re` Expand macro | `Ge` if err |

---

## Внешние зависимости

```bash
brew install lazydocker mongosh
pip install ipython debugpy pytest   # в venv проекта
rustup component add rust-analyzer
```
