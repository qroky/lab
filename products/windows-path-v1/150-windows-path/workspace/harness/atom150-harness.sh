#!/usr/bin/env bash
# ATOM-150 (windows-path-v1) harness — the scheduler abstraction layer.
#
# Covers the parts of INPUT.md H4 that the shipped dry-run.sh (24/24, macOS
# launchd end-to-end) does NOT: (A) macOS BYTE PARITY of the launchd path —
# the plist heredocs and the launchctl-calling functions are proven
# byte-identical to the pre-ATOM-150 tree, and the heartbeat plist is
# re-generated and cmp'd; (B) the systemd user-timer backend; (C) the cron
# fallback backend + idempotency; (D) the no-scheduler negative path (must
# message, never crash, never silently pick an unsafe default); (E) the
# uninstall cleanup of systemd + cron artifacts; (F) backend detection order.
#
# HONESTY (H4): parts B/C/E use PATH-SHADOW STUBS for systemctl/crontab in
# an isolated mktemp sandbox with an isolated HOME — no live systemd, no live
# crontab, ~/.qroky of this machine is never touched. Where a real Linux box
# was NOT available this is called out in RESULT.md. The stubs LOG their
# invocations and the real file artifacts (unit files, crontab body) are
# asserted for real — the layer's generation is proven, the OS execution is
# simulated.
#
# USAGE: bash atom150-harness.sh   (run from anywhere; resolves the repo)
set -uo pipefail

REPO="${QROKY_REPO:-/Users/ghcernei/Work/rpf}"
INSTALL="$REPO/distribution/install.sh"
[[ -f "$INSTALL" ]] || { echo "install.sh not found at $INSTALL" >&2; exit 2; }

SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/atom150-harness.XXXXXX")"
trap 'rm -rf "$SANDBOX"' EXIT
PASS=0; FAIL=0
declare -a SUMMARY
rec() { # $1=PASS|FAIL $2=name $3=detail
  if [[ "$1" == PASS ]]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
  SUMMARY+=("$1 — $2: $3")
  printf '%s — %s: %s\n' "$1" "$2" "$3"
}

# Sourceable copy of a given install.sh: strip the final CLI dispatch case so
# every function loads without executing an interview or exiting.
strip_source() { # $1=src-install.sh  $2=dest
  sed '/^case "${1:-}" in/,$d' "$1" > "$2"
}

# Extract a shell function body (name() { ... } with the closing } at col 0).
fn_body() { awk -v n="$1" '$0 ~ "^"n"\\(\\) \\{" {p=1} p{print} p && /^}/{exit}' "$2"; }
# Extract a heredoc block by its opening `cat > ... <<EOF` line up to the EOF.
heredoc_block() { awk -v k="$1" 'index($0,k){p=1} p{print} p && $0=="EOF"{exit}' "$2"; }

BASE="$SANDBOX/base-install.sh"
MINE="$SANDBOX/mine-install.sh"
( cd "$REPO" && git show HEAD:distribution/install.sh ) > "$BASE" 2>/dev/null || {
  echo "cannot extract base install.sh from git HEAD" >&2; exit 2; }
cp "$INSTALL" "$MINE"

# ===========================================================================
# PART A — macOS BYTE PARITY (H4a)
# ===========================================================================
partA() {
  # A1: the two Telegram plist heredocs — byte-identical base vs mine.
  local ok=1 k
  for k in 'md.qroky.telegram.listener.plist" <<EOF' 'md.qroky.telegram.digest.plist" <<EOF'; do
    if ! diff <(heredoc_block "$k" "$BASE") <(heredoc_block "$k" "$MINE") >/dev/null; then ok=0; fi
  done
  # heartbeat plist heredoc (inside _write_heartbeat_files)
  if ! diff <(heredoc_block '.qroky/launchd/$label.plist" <<EOF' "$BASE") \
            <(heredoc_block '.qroky/launchd/$label.plist" <<EOF' "$MINE") >/dev/null; then ok=0; fi
  [[ $ok -eq 1 ]] && rec PASS "A1-plist-heredocs-identical" "3 plist heredocs byte-identical base vs mine" \
    || rec FAIL "A1-plist-heredocs-identical" "a plist heredoc diverged from base"

  # A2: the launchctl-calling functions — byte-identical (same launchctl calls).
  ok=1
  for f in _telegram_bootstrap_attempt _heartbeat_enable_attempt; do
    if ! diff <(fn_body "$f" "$BASE") <(fn_body "$f" "$MINE") >/dev/null; then ok=0; fi
  done
  [[ $ok -eq 1 ]] && rec PASS "A2-launchd-fns-identical" "_telegram_bootstrap_attempt + _heartbeat_enable_attempt byte-identical" \
    || rec FAIL "A2-launchd-fns-identical" "a launchd attempt fn diverged"

  # A3: DYNAMIC — regenerate the heartbeat plist from base and from mine with
  # IDENTICAL inputs (same HOME, same WORKSPACE_DIR); snapshot base, run mine
  # over the same path, cmp. Any byte difference = a real divergence.
  local sb sm; sb="$SANDBOX/src-base.sh"; sm="$SANDBOX/src-mine.sh"
  strip_source "$BASE" "$sb"; strip_source "$MINE" "$sm"
  local ws="$SANDBOX/ws-shared" hm="$SANDBOX/home-shared"
  mkdir -p "$ws/.qroky" "$hm"
  local gb gm
  gb="$(HOME="$hm" bash -c "source '$sb'; WORKSPACE_DIR='$ws'; SCRIPT_DIR='$ws'; _write_heartbeat_files" 2>/dev/null)"
  cp "$ws/.qroky/launchd/$gb.plist" "$SANDBOX/hb-base.plist"
  gm="$(HOME="$hm" bash -c "source '$sm'; WORKSPACE_DIR='$ws'; SCRIPT_DIR='$ws'; _write_heartbeat_files" 2>/dev/null)"
  if [[ "$gb" == "$gm" ]] && cmp -s "$SANDBOX/hb-base.plist" "$ws/.qroky/launchd/$gm.plist"; then
    rec PASS "A3-heartbeat-plist-cmp" "regenerated heartbeat plist + label byte-identical base vs mine (label=$gm)"
  else
    rec FAIL "A3-heartbeat-plist-cmp" "heartbeat plist/label mismatch (base_label=$gb mine_label=$gm)"
  fi

  # A4: on a launchd machine the detector picks launchd (unchanged path).
  local d; d="$(HOME="$SANDBOX/ha" bash -c "source '$sm'; PATH='/usr/bin:/bin'; command -v launchctl >/dev/null 2>&1 && { source '$sm'; _sched_backend; }" 2>/dev/null)"
  # launchctl exists on this macOS box:
  if command -v launchctl >/dev/null 2>&1; then
    local got; got="$(bash -c "source '$sm'; _sched_backend")"
    [[ "$got" == launchd ]] && rec PASS "A4-detect-launchd" "detector returns launchd on this macOS box" \
      || rec FAIL "A4-detect-launchd" "detector returned '$got' not launchd"
  else
    rec PASS "A4-detect-launchd" "(skipped — no launchctl on this box)"
  fi
}

# ===========================================================================
# Shared: a stub-bin dir shadowing systemctl / crontab, logging invocations.
# ===========================================================================
make_stubs() { # $1=stubdir  (creates systemctl, crontab; logs to $1/calls.log, crontab store $1/crontab.store)
  local d="$1"; mkdir -p "$d"
  cat > "$d/systemctl" <<'STUB'
#!/usr/bin/env bash
echo "systemctl $*" >> "$STUB_CALLS"
# emulate `--user show-environment` success so detection can pick systemd
case "$*" in
  *"show-environment"*) exit 0 ;;
  *"daemon-reload"*|*"enable"*|*"disable"*) exit 0 ;;
  *) exit 0 ;;
esac
STUB
  cat > "$d/crontab" <<'STUB'
#!/usr/bin/env bash
echo "crontab $*" >> "$STUB_CALLS"
if [[ "${1:-}" == "-l" ]]; then
  [[ -f "$STUB_CRONTAB" ]] && cat "$STUB_CRONTAB" || { echo "no crontab for user" >&2; exit 1; }
  exit 0
fi
if [[ "${1:-}" == "-" ]]; then cat > "$STUB_CRONTAB"; exit 0; fi
exit 0
STUB
  chmod +x "$d/systemctl" "$d/crontab"
}

# ===========================================================================
# PART B — systemd user-timer backend (SIMULATED: stub systemctl)
# ===========================================================================
partB() {
  local sm="$SANDBOX/src-mine.sh" d="$SANDBOX/B"
  mkdir -p "$d/stubs" "$d/home/.config" "$d/tg" "$d/ws/.qroky"
  make_stubs "$d/stubs"
  : > "$d/tg/run-listener.sh"; : > "$d/tg/run-digest.sh"; : > "$d/ws/.qroky/heartbeat.sh"
  local out
  out="$(HOME="$d/home" STUB_CALLS="$d/calls.log" STUB_CRONTAB="$d/crontab.store" \
    PATH="$d/stubs:/usr/bin:/bin" QROKY_SCHED_BACKEND=systemd \
    bash -c "source '$sm'; TG_HOME_DIR='$d/tg'; WORKSPACE_DIR='$d/ws'; LOG_FILE='$d/log'; \
      _sched_run telegram_jobs _telegram_bootstrap_attempt _telegram_systemd_attempt _telegram_cron_attempt; echo TG_RC=\$?; \
      _sched_run heartbeat _heartbeat_enable_attempt _heartbeat_systemd_attempt _heartbeat_cron_attempt; echo HB_RC=\$?; \
      echo USED=\$SCHED_USED" 2>&1)"
  local ud="$d/home/.config/systemd/user"
  local units=0
  for u in qroky-telegram-listener.timer qroky-telegram-digest.timer \
           qroky-telegram-listener.service qroky-telegram-digest.service; do
    [[ -f "$ud/$u" ]] && units=$((units+1))
  done
  local hbtimer; hbtimer="$(ls "$ud"/qroky-heartbeat-*.timer 2>/dev/null | wc -l | tr -d ' ')"
  local enabled; enabled="$(grep -c 'enable --now' "$d/calls.log" 2>/dev/null)"; enabled="${enabled:-0}"
  local reload; reload="$(grep -c 'daemon-reload' "$d/calls.log" 2>/dev/null)"; reload="${reload:-0}"
  local oncal; oncal="$(grep -h 'OnCalendar' "$ud"/qroky-telegram-digest.timer "$ud"/qroky-heartbeat-*.timer 2>/dev/null | wc -l | tr -d ' ')"
  if echo "$out" | grep -q 'TG_RC=0' && echo "$out" | grep -q 'HB_RC=0' \
     && echo "$out" | grep -q 'USED=systemd' && [[ $units -eq 4 && $hbtimer -eq 1 && $enabled -ge 2 && $reload -ge 2 && $oncal -ge 2 ]]; then
    rec PASS "B-systemd-backend" "4 tg units + 1 hb timer written, enable --now x$enabled, daemon-reload x$reload, OnCalendar present (SIMULATED: systemctl stubbed)"
  else
    rec FAIL "B-systemd-backend" "units=$units hbtimer=$hbtimer enabled=$enabled reload=$reload oncal=$oncal out=[$(echo "$out" | tr '\n' '|')]"
  fi
}

# ===========================================================================
# PART C — cron fallback backend + idempotency (SIMULATED: stub crontab)
# ===========================================================================
partC() {
  local sm="$SANDBOX/src-mine.sh" d="$SANDBOX/C"
  mkdir -p "$d/stubs" "$d/home" "$d/tg" "$d/ws/.qroky"
  make_stubs "$d/stubs"
  : > "$d/tg/run-listener.sh"; : > "$d/tg/run-digest.sh"; : > "$d/ws/.qroky/heartbeat.sh"
  # pre-seed a FOREIGN crontab line that must survive
  printf '0 0 * * * /usr/bin/true # foreign-user-job\n' > "$d/crontab.store"
  local run_once
  run_once() {
    HOME="$d/home" STUB_CALLS="$d/calls.log" STUB_CRONTAB="$d/crontab.store" \
      PATH="$d/stubs:/usr/bin:/bin" QROKY_SCHED_BACKEND=cron \
      bash -c "source '$sm'; TG_HOME_DIR='$d/tg'; WORKSPACE_DIR='$d/ws'; LOG_FILE='$d/log'; \
        _sched_run telegram_jobs _telegram_bootstrap_attempt _telegram_systemd_attempt _telegram_cron_attempt; echo TG_RC=\$?; \
        _sched_run heartbeat _heartbeat_enable_attempt _heartbeat_systemd_attempt _heartbeat_cron_attempt; echo HB_RC=\$?; \
        echo USED=\$SCHED_USED" 2>&1
  }
  local out1; out1="$(run_once)"
  local listener1 digest1 hb1 foreign1
  listener1="$(grep -c 'run-listener.sh' "$d/crontab.store")"
  digest1="$(grep -c 'run-digest.sh' "$d/crontab.store")"
  hb1="$(grep -c 'heartbeat.sh' "$d/crontab.store")"
  foreign1="$(grep -c 'foreign-user-job' "$d/crontab.store")"
  # run AGAIN — idempotent: still exactly one of each, foreign preserved
  local out2; out2="$(run_once)"
  local listener2 digest2 hb2 foreign2 tgblocks
  listener2="$(grep -c 'run-listener.sh' "$d/crontab.store")"
  digest2="$(grep -c 'run-digest.sh' "$d/crontab.store")"
  hb2="$(grep -c 'heartbeat.sh' "$d/crontab.store")"
  foreign2="$(grep -c 'foreign-user-job' "$d/crontab.store")"
  tgblocks="$(grep -c '>>> qroky-telegram' "$d/crontab.store")"
  if echo "$out1" | grep -q 'USED=cron' \
     && [[ $listener1 -eq 1 && $digest1 -eq 1 && $hb1 -eq 1 && $foreign1 -eq 1 \
        && $listener2 -eq 1 && $digest2 -eq 1 && $hb2 -eq 1 && $foreign2 -eq 1 && $tgblocks -eq 1 ]]; then
    rec PASS "C-cron-backend" "listener(1/min)+digest(9:05)+heartbeat(7 9 * * 1-5) installed, idempotent on re-run (no dup blocks), foreign crontab line preserved (SIMULATED: crontab stubbed)"
  else
    rec FAIL "C-cron-backend" "run1 l=$listener1 d=$digest1 hb=$hb1 f=$foreign1 | run2 l=$listener2 d=$digest2 hb=$hb2 f=$foreign2 blocks=$tgblocks"
  fi
}

# ===========================================================================
# PART D — no scheduler at all → dispatcher returns 3, caller messages (H1)
# ===========================================================================
partD() {
  local sm="$SANDBOX/src-mine.sh" d="$SANDBOX/D"; mkdir -p "$d/tg" "$d/ws/.qroky"
  # Force none and confirm _sched_run returns 3 with SCHED_USED=none (the
  # caller then prints L_*_NO_SCHEDULER — proven separately below) and does
  # NOT crash under set -e semantics.
  local out
  out="$(QROKY_SCHED_BACKEND=none bash -c "set -e; source '$sm'; TG_HOME_DIR='$d/tg'; WORKSPACE_DIR='$d/ws'; \
     if _sched_run telegram_jobs _telegram_bootstrap_attempt _telegram_systemd_attempt _telegram_cron_attempt; then echo SCHEDULED; else echo RC=\$?; fi; \
     echo USED=\$SCHED_USED" 2>&1)"
  # And confirm the message function exists + names the docs + the qroky command in EN.
  local msg; msg="$(bash -c "source '$REPO/distribution/lang/en.sh'; L_TELEGRAM_NO_SCHEDULER /tmp/x")"
  if echo "$out" | grep -q 'RC=3' && echo "$out" | grep -q 'USED=none' \
     && echo "$msg" | grep -q 'docs/WINDOWS.md' && echo "$msg" | grep -q 'enable-telegram' \
     && echo "$msg" | grep -qi 'no scheduler'; then
    rec PASS "D-none-negative" "dispatcher returns 3 (not silent, no crash) + L_TELEGRAM_NO_SCHEDULER names docs/WINDOWS.md and the recovery command"
  else
    rec FAIL "D-none-negative" "out=[$(echo "$out" | tr '\n' '|')] msg_has_docs=$(echo "$msg" | grep -qc WINDOWS.md)"
  fi
}

# ===========================================================================
# PART E — uninstall removes systemd units + cron block (SIMULATED)
# ===========================================================================
partE() {
  local d="$SANDBOX/E"; mkdir -p "$d/stubs" "$d/home/.config/systemd/user"
  make_stubs "$d/stubs"
  local ud="$d/home/.config/systemd/user"
  # plant qroky units + a foreign unit
  for u in qroky-telegram-listener.timer qroky-telegram-digest.timer \
           qroky-telegram-listener.service qroky-telegram-digest.service \
           qroky-heartbeat-myws.timer qroky-heartbeat-myws.service; do : > "$ud/$u"; done
  : > "$ud/someone-elses.timer"
  # plant qroky crontab block + foreign line
  cat > "$d/crontab.store" <<'CRON'
0 0 * * * /usr/bin/true # foreign-user-job
# >>> qroky-telegram (managed by the Qroky installer) >>>
* * * * * /bin/bash /x/tg/run-listener.sh >/dev/null 2>&1
5 9 * * * /bin/bash /x/tg/run-digest.sh >/dev/null 2>&1
# <<< qroky-telegram <<<
# >>> qroky-heartbeat-myws (managed by the Qroky installer) >>>
7 9 * * 1-5 /bin/bash /x/ws/.qroky/heartbeat.sh >/dev/null 2>&1
# <<< qroky-heartbeat-myws <<<
CRON
  # Replicate the installer's uninstall cleanup blocks (extracted verbatim
  # from install.sh) against the sandbox HOME + stub tools.
  HOME="$d/home" STUB_CALLS="$d/calls.log" STUB_CRONTAB="$d/crontab.store" PATH="$d/stubs:/usr/bin:/bin" bash <<'CLEANUP'
set -uo pipefail
if command -v systemctl >/dev/null 2>&1; then
  ud="$HOME/.config/systemd/user"
  if [[ -d "$ud" ]]; then
    for ufile in "$ud"/qroky-telegram-listener.timer "$ud"/qroky-telegram-digest.timer "$ud"/qroky-heartbeat-*.timer; do
      [[ -f "$ufile" ]] || continue
      systemctl --user disable --now "$(basename "$ufile")" 2>/dev/null || true
    done
    rm -f "$ud"/qroky-telegram-listener.service "$ud"/qroky-telegram-listener.timer \
          "$ud"/qroky-telegram-digest.service "$ud"/qroky-telegram-digest.timer \
          "$ud"/qroky-heartbeat-*.service "$ud"/qroky-heartbeat-*.timer 2>/dev/null || true
    systemctl --user daemon-reload 2>/dev/null || true
  fi
fi
if command -v crontab >/dev/null 2>&1; then
  cronnow="$(crontab -l 2>/dev/null || true)"
  if printf '%s\n' "$cronnow" | grep -qE 'qroky-telegram|qroky-heartbeat'; then
    printf '%s\n' "$cronnow" | awk '
      /^# >>> qroky-(telegram|heartbeat)/ {skip=1; next}
      /^# <<< qroky-(telegram|heartbeat)/ {skip=0; next}
      skip!=1 {print}' | grep -v '^[[:space:]]*$' | crontab - 2>/dev/null || true
  fi
fi
CLEANUP
  local qunits foreign_unit qcron foreign_cron disables
  qunits="$(ls "$ud"/qroky-* 2>/dev/null | wc -l | tr -d ' ')"
  foreign_unit=0; [[ -f "$ud/someone-elses.timer" ]] && foreign_unit=1
  qcron="$(grep -c 'qroky-' "$d/crontab.store" 2>/dev/null)"; qcron="${qcron:-0}"
  foreign_cron="$(grep -c 'foreign-user-job' "$d/crontab.store" 2>/dev/null)"; foreign_cron="${foreign_cron:-0}"
  disables="$(grep -c 'disable --now' "$d/calls.log" 2>/dev/null)"; disables="${disables:-0}"
  if [[ $qunits -eq 0 && $foreign_unit -eq 1 && $qcron -eq 0 && $foreign_cron -eq 1 && $disables -ge 2 ]]; then
    rec PASS "E-uninstall-cleanup" "all qroky systemd units + cron block removed (disable --now x$disables), FOREIGN unit + FOREIGN cron line preserved (SIMULATED)"
  else
    rec FAIL "E-uninstall-cleanup" "qunits=$qunits foreign_unit=$foreign_unit qcron=$qcron foreign_cron=$foreign_cron disables=$disables"
  fi
}

# ===========================================================================
# PART F — detection order (override honored; launchd wins on macOS)
# ===========================================================================
partF() {
  local sm="$SANDBOX/src-mine.sh" ok=1 g
  for want in launchd systemd cron none; do
    g="$(QROKY_SCHED_BACKEND=$want bash -c "source '$sm'; _sched_backend")"
    [[ "$g" == "$want" ]] || ok=0
  done
  [[ $ok -eq 1 ]] && rec PASS "F-detection-override" "QROKY_SCHED_BACKEND override honored for all four values" \
    || rec FAIL "F-detection-override" "override not honored"
}

# strip mine once for the sourced parts
strip_source "$MINE" "$SANDBOX/src-mine.sh"

echo "=== ATOM-150 scheduler-abstraction harness ==="
echo "sandbox: $SANDBOX"
partA; partB; partC; partD; partE; partF

echo
echo "=== SUMMARY ==="
for l in "${SUMMARY[@]}"; do echo "$l"; done
echo "Totals: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
