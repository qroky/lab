# INFO-046 — Windows-путь: спрос сработал на первом получателе волны №1

- **Тип:** INFO (решение CEO; исключение из моратория INFO-036/043 — фиксация
  решения CEO, новых конституционных практик не создаёт)
- **Дата:** 12.07.2026

## Событие и слово CEO

Волна №1 разослана в день G2 (GATE-034): два тёплых получателя — один на
Windows, второй на macOS. Триггер «первый же контакт на Windows» сработал
немедленно. Решение CEO (цитата анонимизирована по политике GATE-032 —
личные детали получателей в публичную шину не едут):

> уже надо делать для windows потому что отправил [получателю №1], а у него
> Windows, у [получателя №2] — Mac

## Решение

1. **Windows-путь строится СЕЙЧАС** — вне очереди INFO-043 (scripts/verify.sh
   сдвигается за ним; lex posterior — живой спрос волны №1 и есть тот фидбек,
   ради которого выстраивался порядок).
2. **Форма v1 — WSL2, не нативный порт**: ядро (markdown+git+Claude Code)
   платформонезависимо; кит уже деградирует честно без launchd
   (L_*_NO_LAUNCHD). Дыра — только контур расписания (heartbeat, Telegram
   listener/digest). Строится: абстракция планировщика
   launchd / systemd user timers / cron + Windows-quickstart (WSL2) +
   Linux-прогон харнеса. Нативный Windows (PowerShell) остаётся NOT-DOING
   до отдельного решения — это форк/binding per runtime/INTERFACE.md.
3. **Атом:** ATOM-150 (windows-path-v1), конверт ~250k (INFO-019 flagged
   practice per GATE-022): executor ~180k, blind mutation-verify ~70k.
4. **Зачёт по INFO-035:** правка install.sh = новый короткий зачётный прогон.
   Живой прогон получателя №1 на Windows/WSL2 = валидационный прогон и
   одновременно «первый внешний пользователь» из критерия готовности
   launch-чеклиста.

## Следствие для витрины

README-строка о платформах уже честна («scheduled extras use macOS launchd —
other platforms go through runtime bindings»); после ATOM-150 она обновится
на «macOS and Linux/WSL2» тем же атомом.
