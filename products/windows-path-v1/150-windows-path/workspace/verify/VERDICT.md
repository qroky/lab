# BLIND VERIFY — ATOM-150 (windows-path-v1) — VERDICT

Method: mutation falsification (INFO-037). Canon: INPUT.md only (blindness held —
executor RESULT/run.log/harness/NARRATIVE/STATUS not opened). Code under test:
`~/Work/rpf` branch `atom-150-windows-path`, `git diff 542cb15..HEAD` (321bc85,
2933682, 6d6dbb0). Read-only on repo; all mutations in mktemp copies; ~/.qroky
never touched.

## ITOG: RETURN

One blocking finding (state-persistence bug, F1). Everything else PASS, incl. the
macOS byte-parity gate. The blocker is a one-line subshell-scope fix; re-verify F1
only.

## H-point table

| H | Verdict | Evidence |
|---|---------|----------|
| H1 scheduler layer | **PARTIAL** | ONE detector `_sched_backend` + ONE dispatcher `_sched_run` over launchd/systemd/cron; launchd checked FIRST (proved: mutation M1 reordering cron-before-launchd flips detect from `launchd`→`cron` with all three present). Every consumer (telegram listener+digest, heartbeat, `--enable-heartbeat`, `--enable-telegram`, install `step_*`) routes through `_sched_run` — grep shows direct `launchctl` only inside the two launchd backend fns + uninstall, no bypass. Zero new interview questions (harness question-inventory: max IV-POINT=8, q9 gone). Negative degradation honest (T2/T3/M2). **BUT** backend NOT persisted to install-state.json → see F1 blocking. |
| H1 macOS BYTE-PARITY (gate) | **PASS** | (1) static `cmp`: `_telegram_bootstrap_attempt` (11 lines) and `_heartbeat_enable_attempt` (8 lines) byte-identical 542cb15↔HEAD; plist heredoc region md5 identical (`e8f0a438…`). (2) `_sched_run` launchd branch calls `run_with_ladder <tag> <launchd_fn>` — same tag/fn as old direct call; dispatch unit-test T6 shows only the launchd fn is invoked. (3) shipped `dry-run.sh` on macOS: 24/24 green on unmutated HEAD. (4) mutation: neutering the launchd bootstrap in a copy → scenario 8 fails (`bootstrapped_y=0`), so the parity path is covered by a test that dies when it breaks. No launchd byte changed. |
| H2 Linux end-to-end | **PASS** | `L_*_NO_LAUNCHD`→`L_*_NO_SCHEDULER` + new `L_SCHED_CRON_NOTE` in all three locales; **zero** orphan `NO_LAUNCHD` refs anywhere shipped. Key-set parity exact: 104 `L_*` names, en==ro==ru (diff empty). Launcher/PATH block writes bash profiles: `_profile_file` → `.bashrc` for `*/bash`, `.profile` fallback; marker scan covers `.bashrc/.bash_profile/.profile` (unchanged ATOM-131 capability, intact). systemd/cron unit generation content correct (T7–T10). |
| H3 docs/WINDOWS.md + README | **PASS** | WINDOWS.md exists, EN-only, WSL2 in 3 steps (`wsl --install`, `systemd=true` in /etc/wsl.conf w/ explanation, git+Claude Code inside WSL), SAME curl one-liner, honest boundaries incl. "not yet through a living Windows run". Ships to users: `docs/` is a whole-directory entry in dist-manifest (line 16) → WINDOWS.md travels. README: platform line changed in place to "run on macOS and Linux/WSL2 — launchd on a Mac, systemd user timers or cron elsewhere" + link; one line, no new section, hero untouched. |
| H4 harness | **PASS** | (a) macOS parity green + cmp proof (above). (b) Linux: live Linux NOT raised (Docker not started — see note); systemd/cron backends proven by isolated unit + mutation probes on real function code (PATH-shadow stubs). (c) negative degradation covered: none-present → `_sched_run` rc=3, no consumer fn called, `SCHED_USED=none` (T3); mutation M2 (silent `return 0`) is caught. Shipped harness untouched by this atom and still 24/24. |
| H5 CHANGELOG v0.5 | **PASS** | v0.5 entry present, benefit language ("Windows via WSL2 and Linux are now first-class… your Mac install doesn't change a byte"). `git tag` carries NO v0.5 (tags stop at v0.4.2). |
| H6 blind mutation verify | **PASS (method)** | Executed: 4 scheduler-layer mutations (M1 order, M2 silent-none, M3 systemd ExecStart, M4 cron cadence) all CAUGHT; 1 macOS-path mutation CAUGHT by shipped scenario 8. |
| Soft S1 | PASS | NO_SCHEDULER/CRON_NOTE messages give action→status→exact fix (systemd=true, pointer to WINDOWS.md), never silent. |

## macOS byte-parity (GATE): PASS
Independently proven, not taken from self-report: launchd backend fns + plist
heredocs byte-identical across 542cb15↔HEAD; launchd dispatch path equivalent;
24/24 shipped scenarios green on macOS; a deliberate launchd-path break is caught.
Not one byte of the Mac path changed.

## dry-run.sh / ATOM_WORKSPACE_SRC: internal test artifact, non-blocking NOTE
`dry-run.sh:68` sets `ATOM_WORKSPACE_SRC="$HERE/../products/distribution-kit-v1/131-qroky-command/workspace"`,
a factory path removed by SEPARATION. Assessment: (1) dry-run.sh DOES ship
(`distribution/` is a whole-dir manifest entry) but is a dev harness — nothing in
the user journey (qroky.sh, any command, install/update/uninstall) invokes it.
(2) If a user manually ran it, `mkdir -p` would create an empty `framework/products/…`
dir — and `framework/` is itself whitelisted whole, so it would NOT trip the freeze
check. Harmless litter. (3) Pre-existing from ATOM-131 (baseline 542cb15); ATOM-150
did not touch dry-run.sh. Verdict: not a defect of this atom; worth a future cleanup
(a shipped harness should not point at removed factory paths), NOTE severity.

## Findings

- **F1 — BLOCKING — backend never persisted to install-state.json (subshell scope bug).**
  `_sched_run` does `SCHED_USED="$(_sched_backend)"`; the detector assigns the global
  `SCHED_BACKEND` **inside the `$(…)` subshell**, so the parent's `SCHED_BACKEND`
  stays `""`. `state_commit` writes `"sched_backend": "$SCHED_BACKEND"` → always `""`.
  Proven live: a full clean install (launchd path taken) yields `sched_backend: ""`
  in install-state.json; focused experiment shows `SCHED_USED='launchd'` but
  `SCHED_BACKEND=''` after `_sched_run`. The code comment (install.sh:156) states the
  field is "persisted" — the record silently contradicts the claim. Impact: functional
  scheduling is CORRECT on every backend (dispatch/messages use `SCHED_USED`), but the
  install-state.json diagnostic the coordinator will read for the wave-1 Windows living
  run to learn "systemd or cron?" is empty for every instance. A "no silent holes"
  framework must not ship a state field that claims a value and always records nothing.
  Mutation status: this IS the falsification — flipping the code to set the global
  (e.g. `SCHED_USED="$(_sched_backend)"; SCHED_BACKEND="$SCHED_USED"`, or call
  `_sched_backend >/dev/null` in-parent then read `$SCHED_BACKEND`) makes the field
  populate. One-line fix. Note: INPUT.md H1 does not itself enumerate state
  persistence, but the executor implemented it, commented it as done, and it does not
  work — a real defect + false record.

- **F2 — minor/NOTE — sched_backend only meaningful once a scheduling consumer runs.**
  Even after F1 is fixed, if both Telegram and heartbeat are declined, `_sched_run` is
  never called and `sched_backend` stays empty. Acceptable (no scheduling attempted),
  but worth a one-time detect-at-install so the field always reflects the machine.

- **F3 — NOTE — dry-run.sh ATOM_WORKSPACE_SRC** (see dedicated section above).

## Gate checks
- `bash -n`: clean on install.sh, lang/{en,ro,ru}.sh, dry-run.sh, verify.sh, qroky.sh.
- verify.sh FREEZE-CHECK: OK on clean `git archive HEAD` export (12 manifest entries, exit 0).
- Secrets / `/Users/ghcernei`: none in any shipped file (grep clean; the "secret"
  hits are legitimate masking code / copy).
- EOF / non-interactive: backend is auto-DETECTED, not asked; no silent unsafe pick —
  cron path always surfaces `L_SCHED_CRON_NOTE`, none path surfaces NO_SCHEDULER; systemd
  detection is conservative (requires `/run/systemd/system` AND a live `--user` bus, so a
  WSL2 box without `systemd=true` correctly falls to cron, not a dead systemd).
- main + tags untouched (branch not switched, no commit/push, no v0.5 tag).

## NOT-DOING: respected
No PowerShell/native port (only negated + used as the terminal for the user's own
`wsl --install`); kit never installs WSL (WINDOWS.md:119 says so explicitly); WSL1
only "not supported".

## Live Linux
Not raised — did not start Docker; Linux backends validated via isolated function-level
mutation probes + macOS parity + static read. Honest gap, matches WINDOWS.md's own
boundary statement.

---
Recorded by blind L-tier verifier, 2026-07-12. Single permitted write.
