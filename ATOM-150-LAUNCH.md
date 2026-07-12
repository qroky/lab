# LAUNCH — ATOM-150 (windows-path-v1: WSL2/Linux как первоклассный путь установки)

> Runtime instruction. Мандат: INFO-046 (решение CEO 12.07.2026 — спрос волны
> №1: первый получатель на Windows). G1 = слово CEO «уже надо делать для
> windows» (записано INFO-046). Исполнение по пяти конституционным документам
> и runtime/claude/README.md. Бюджет (INFO-019 flagged practice per GATE-022):
> поддерево ~250k — executor ~180k (M), blind mutation-verify ~70k (L).
> E4 только на пробой.

---
atom: ATOM-150
product: Windows path v1 — WSL2/Linux first-class install (scheduler abstraction + quickstart + Linux-proofed kit)
parent: — (top-level; спрос волны №1, INFO-046)
role: pilot-toolsmith (reuse, F2)
formulated_by: координатор из INFO-046, 12.07.2026
verification: independent blind (L) + мутационная фальсификация (INFO-037)
maturity_target: reviewed (validated — после живого прогона получателя волны №1 на Windows)
budget: ~250k subtree (INFO-019 flagged)
recursion_allowance: 1
---

## 1. Job To Be Done

Человек на Windows получает тот же честный путь ≤15 минут, что и на macOS:
ставит WSL2 по одной странице документации, запускает ТОТ ЖЕ
curl-однострочник, проходит те же 8 вопросов — и получает работающий
инстанс, включая контур расписания (дайджест, Telegram), а не усечённый
режим. macOS-поведение не меняется ни на байт.

## 2. Definition of Done

**Hard:**
- H1. **Абстракция планировщика** в ките: один внутренний слой
  (schedule_install/schedule_remove/schedule_status или эквивалент), три
  бэкенда с автоопределением: launchd (macOS, поведение БАЙТ-идентично
  текущему — доказать харнесом), systemd user timers (Linux/WSL2 с
  systemd), cron (fallback). Все потребители расписания (heartbeat,
  telegram listener + digest) ходят только через слой. Нет ни systemd, ни
  cron → честное сообщение по образцу L_*_NO_LAUNCHD с указанием на доку
  (never silent, never полуустановка).
- H2. **Linux-путь цел end-to-end**: install (8 вопросов) / update /
  uninstall / enable-telegram / enable-heartbeat / enable-backup на
  Linux-bash проходят; launcher `~/.local/bin/qroky` и PATH-блок работают
  в bash-профилях (`.bashrc`/`.profile` — на Linux дефолт bash, не zsh);
  machine trace `~/.qroky/workdir` без macOS-специфики. Все
  L_*_NO_LAUNCHD-тексты заменены/дополнены: указывают новый слой и доку,
  а не тупик.
- H3. **docs/WINDOWS.md** (EN-only, в manifest): WSL2 за 3 шага
  (`wsl --install`, systemd=true в /etc/wsl.conf с объяснением, git +
  Claude Code внутри WSL), затем ТОТ ЖЕ curl-однострочник; известные
  отличия (пути, где живёт workspace, как открыть в VS Code через WSL);
  честные границы (что не проверено живым прогоном — сказано прямо).
  README: строка платформ обновлена (macOS and Linux/WSL2 + ссылка на
  доку), длиной в одну-две строки, без нового раздела.
- H4. **Харнес**: (а) macOS байт-паритет — существующие сценарии зелёные,
  плюс cmp-доказательство, что на macOS новый слой генерит тот же plist и
  те же вызовы launchctl; (б) Linux-прогон — через Docker
  (демон можно поднять: `open -a Docker`, подождать), образ ubuntu с
  bash+git+cron+systemd-заглушкой ИЛИ, если Docker недоступен, честная
  симуляция (launchctl/systemd shadow через PATH) с явной пометкой в RESULT,
  что живого Linux не было; (в) негативные тесты деградации (нет systemd
  и нет cron → сообщение, не молчание и не падение).
- H5. **CHANGELOG v0.5** — запись языком пользы (Windows via WSL2 and
  Linux are now first-class; your Mac install doesn't change a byte).
  Тег НЕ вешать — тегует координатор после verify и зачёта.
- H6. Blind verify: accept, мутационный метод (INFO-037) — сломать бэкенд
  systemd/cron в копии → тест обязан упасть; сломать macOS-путь → байт-
  паритет обязан поймать.

**Soft:**
- S1. Тексты установщика на Linux читаются так же спокойно, как на macOS:
  действие / статус / точный фикс (дисциплина INFO-044 «решить, а не
  подсказывать»).

**NOT-DOING (v1):** нативный Windows/PowerShell порт (форк/binding per
runtime/INTERFACE.md — отдельное решение CEO); поддержка WSL1; автоустановка
WSL самим китом.

## 3. Метод (не связывает)

- Кит уже деградирует честно (install.sh:906, 1188 — command -v launchctl):
  строить слой вокруг этих точек, не переписывая лестницу run_with_ladder.
- systemd user units в WSL2: `systemctl --user`, linger может отсутствовать —
  проверить и задокументировать; cron в WSL2 не автозапускается — если
  выбран cron-бэкенд, честно сказать про запуск службы.
- INFO-035: правка install.sh = короткий зачётный прогон; живой прогон
  получателя волны №1 на Windows = валидация (координатор ведёт).

## 4. Записи

Материализация: products/windows-path-v1/150-windows-path/ в lab (INPUT.md
verbatim, STATUS.md, status.yaml, NARRATIVE.md — ведёт координатор).
Правки кода: ~/Work/rpf, локальная ветка `atom-150-windows-path`, БЕЗ push
(merge+тег — координатор после verify). Workspace исполнителя:
products/windows-path-v1/150-windows-path/workspace/.

---
*Сформулировано 12.07.2026 по INFO-046. Очередь INFO-043 сдвинута решением
CEO: ATOM-150 → scripts/verify.sh → далее по порядку.*
