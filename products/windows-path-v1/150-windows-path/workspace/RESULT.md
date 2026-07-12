# RESULT — ATOM-150 (windows-path-v1)

**Role:** pilot-toolsmith · **Date:** 12.07.2026 · **Branch:** `atom-150-windows-path` (local, NO push, NO tag)
**Envelope:** ~180k executor · **Verdict target:** blind verify accept + mutation falsification (H6, coordinator)

Delivered a surgical **scheduler abstraction** over the distribution kit so Windows-via-WSL2 and
Linux are first-class install targets, with macOS proven byte-identical. Recovery from the prior
API-limit crash: the uncommitted partial `en.sh`/`ro.sh` edits (rename `L_*_NO_LAUNCHD` →
`L_*_NO_SCHEDULER`, add `L_SCHED_CRON_NOTE`) were **assessed correct and on-mandate**, kept, and
completed to full 3-language parity — nothing lost, nothing doubled.

## Commits (local only)

| Hash | Message |
|------|---------|
| `321bc85` | feat: evolve `L_*_NO_LAUNCHD` → `L_*_NO_SCHEDULER` + `L_SCHED_CRON_NOTE` across en/ro/ru |
| `2933682` | feat: scheduler abstraction layer (launchd/systemd/cron autodetect) |
| `6d6dbb0` | docs: WSL2/Linux quickstart + README platform line + CHANGELOG v0.5 |

## H-points

### H1 — Scheduler abstraction ✅ (proven)
One detector `_sched_backend()` + one dispatcher `_sched_run()` over three backends:
`launchd` (macOS) → `systemd` user timers (Linux/WSL2 with a live systemd bus) → `cron` (fallback)
→ `none`. Detection order puts **launchd first**, so a Mac is always the unchanged path;
`QROKY_SCHED_BACKEND` overrides for deterministic harness runs. All three consumers (Telegram
listener+digest, morning heartbeat — install-time step, `--enable-heartbeat`, and `--enable-telegram`)
enable through the layer. Built **around** the existing `command -v launchctl` guards at
install.sh:906/1188/1503 — `run_with_ladder` was not rewritten; the launchd attempt functions
(`_telegram_bootstrap_attempt`, `_heartbeat_enable_attempt`) are **called verbatim**. **Zero new
interview questions.** Backend recorded in `install-state.json` (`sched_backend`).

### H2 — Linux end-to-end ✅ (cron+detection proven on real Linux; texts done)
- `L_*_NO_SCHEDULER` texts (3 langs) evolved: found systemd/cron → works silently; nothing → honest
  fix naming the exact WSL2 systemd steps + `docs/WINDOWS.md`, plus the manual-run fallback. New
  `L_SCHED_CRON_NOTE` surfaces the WSL2 cron-service caveat. **Key parity 104/104/104, names identical.**
- Launcher `~/.local/bin/qroky` and the PATH block **already** cover bash profiles
  (`.bashrc`/`.bash_profile`/`.profile`) from ATOM-131 (`_launcher_profile` + marker scan) — verified,
  no change needed.
- Real-Linux run (Ubuntu 22.04, bash 5.1.16): autodetection lands on `cron`, the cron backend writes
  to the **real** `crontab` binary, idempotent on re-run, foreign crontab line preserved.

### H3 — Docs ✅
- `docs/WINDOWS.md` (EN-only): WSL2 in three steps (`wsl --install`; `systemd=true` in `/etc/wsl.conf`
  *with the why*; git + Claude Code inside WSL), then the **same** curl one-liner; known differences
  (where files live, systemd vs launchd, `~/.local/bin` launcher + `.bashrc` PATH, VS Code via the WSL
  extension); honest boundaries (not yet through a full living Windows install; WSL1 unsupported; kit
  does not install WSL). `docs/` already ships whole via `dist-manifest`, so the page is in the kit
  (freeze check confirms). No new manifest entry needed.
- `README.md` known-limits line updated **minimally** (one line): "macOS and Linux/WSL2" with a link to
  the guide. No new section.

### H4 — Harness ✅ (macOS byte-parity + Linux + negatives)
Two harnesses, **33/33 green**:
- **Shipped `distribution/dry-run.sh` — 24/24** (macOS launchd end-to-end, launchctl-stub). Re-run
  against the modified install.sh: all green, i.e. the dispatch refactor did not disturb the launchd
  path. This is the "existing scenarios green" leg of H4a and it really generates + bootstraps plists.
- **`harness/atom150-harness.sh` — 9/9** (the ATOM-150-specific coverage dry-run.sh lacks):
  - **A1** the three plist heredocs byte-identical base-vs-mine; **A2** the two launchctl-calling
    functions byte-identical (⇒ same launchctl calls); **A3** DYNAMIC — heartbeat plist re-generated
    from base and mine with identical inputs and `cmp`-identical; **A4** detector picks launchd on this
    Mac. → **macOS byte-parity proven (cmp), H4a.**
  - **B** systemd backend: 4 tg units + 1 hb timer written, `enable --now`/`daemon-reload` called,
    `OnCalendar` present.
  - **C** cron backend: listener(1/min)+digest(09:05)+heartbeat(weekdays 09:07), **idempotent** on
    re-run (no duplicate blocks), foreign crontab line preserved.
  - **D** negative — no scheduler → dispatcher returns 3, `SCHED_USED=none`, no crash under `set -e`,
    and `L_TELEGRAM_NO_SCHEDULER` names `docs/WINDOWS.md` + the recovery command (**never silent, never
    a half-install**).
  - **E** uninstall removes all qroky systemd units + the cron block (foreign unit + foreign cron line
    preserved).
  - **F** detection override honored for all four values.
- **Real Linux (Docker `ubuntu:22.04`) — 5/5** (`harness/linux-in-container.sh`): real autodetection→cron,
  real `crontab` write + idempotency, none-degradation, `bash -n`, and the full 9-check harness green on
  Linux bash too.
- **Non-vacuity (mutation) proven:** tweaking a macOS plist minute makes A1/A3 FAIL; removing the cron
  digest line makes C FAIL. The harness catches exactly the breakage H6 asks for.

**Proven vs simulated (honest):**
- **Proven on real Linux:** backend autodetection, the cron backend (real `crontab`), the none path,
  bash portability (bash 5.1), the whole layer running under Linux bash.
- **Proven on macOS:** the launchd path end-to-end (dry-run 24/24) + byte-parity by cmp.
- **Simulated (stubbed `systemctl`, no live systemd bus available in the container):** the **systemd
  backend** — the unit files it writes and the `systemctl --user enable --now`/`daemon-reload` calls are
  asserted for real, but a live systemd *executing* the timers was not exercised. A full living Windows
  (WSL2 + systemd) install by the wave-1 recipient remains the validation step (INFO-035, coordinator).

### H5 — CHANGELOG v0.5 ✅ (no tag)
Entry added in user-benefit language ("Windows via WSL2 and Linux are now first-class"; "your Mac
install doesn't change a byte"; the honest no-scheduler note). Tag deliberately **not** applied —
coordinator tags after verify + acceptance.

### H6 — Verify (coordinator) — falsification-ready
Blind verify + mutation is the L-tier verifier's job. The harness is built to be falsified: the two
mutation classes H6 names (break systemd/cron backend; break the macOS path) are demonstrated to flip
the relevant checks red.

## Point-6 gates
- `bash -n` OK: install.sh, lang/en|ro|ru.sh, dry-run.sh.
- `verify.sh` on a clean `git archive HEAD` export → **FREEZE-CHECK OK** (12 manifest entries;
  `docs/WINDOWS.md` accepted under `docs/`, langs under `distribution/`).
- Lang key parity: **104 = 104 = 104**, key-name sets identical across en/ro/ru.

## Invariants honored
- **macOS not one byte** where it counts: plist heredocs + launchctl-calling functions byte-identical
  (cmp); launchd is detected first so the Mac branch is the literal old path. (`install-state.json` gains
  a `sched_backend` field — the deliberate, mandated H4c record; on a Mac its value is `launchd`. The
  uninstall adds a **read-only** `crontab -l` probe that modifies nothing when no qroky markers exist —
  no plist/launchctl change; dry-run uninstall scenarios 15/21/22 still green.)
- No push, no tags, `main` untouched. `~/.qroky` of this machine never touched (harness only in
  mktemp/isolated-HOME sandboxes; container crontab is ephemeral). Secrets not read/logged.
- EOF/non-interactive never silently picks an unsafe default: `none` always yields an explicit message.

## Spend
Executor run within the ~180k envelope (single session incl. the crash-recovery orientation). No E4.
