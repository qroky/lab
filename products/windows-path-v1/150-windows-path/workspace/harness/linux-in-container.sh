#!/usr/bin/env bash
# Runs INSIDE an ubuntu container (see run-linux-docker.sh). Proves the
# scheduler layer on REAL Linux bash: (1) autodetection with no launchd/no
# systemd running lands on cron; (2) the cron backend writes to the REAL
# crontab binary and is idempotent; (3) none-override degrades honestly;
# (4) install.sh passes bash -n under Linux bash; (5) the full 9-check
# atom150-harness runs green on Linux bash too.
set -uo pipefail
REPO=/repo
SM=/tmp/src-mine.sh
sed '/^case "${1:-}" in/,$d' "$REPO/distribution/install.sh" > "$SM"

echo "### env: $(bash --version | head -1)"
echo "### crontab: $(command -v crontab || echo MISSING) | systemctl: $(command -v systemctl || echo MISSING) | launchctl: $(command -v launchctl || echo MISSING)"

fails=0
mark(){ if [[ "$1" == PASS ]]; then echo "PASS — $2"; else echo "FAIL — $2"; fails=$((fails+1)); fi; }

# 1) real autodetection → cron (no launchd, no running systemd bus)
got="$(bash -c "source '$SM'; _sched_backend")"
[[ "$got" == cron ]] && mark PASS "L1 autodetect=cron on this Linux box" || mark FAIL "L1 autodetect=$got (expected cron)"

# 2) cron backend against the REAL crontab
mkdir -p /root/tg /root/ws/.qroky; : >/root/tg/run-listener.sh; : >/root/tg/run-digest.sh; : >/root/ws/.qroky/heartbeat.sh
crontab -r 2>/dev/null || true
printf '0 0 * * * /bin/true # foreign\n' | crontab -
bash -c "source '$SM'; TG_HOME_DIR=/root/tg; WORKSPACE_DIR=/root/ws; LOG_FILE=/tmp/log; \
  _sched_run telegram_jobs _telegram_bootstrap_attempt _telegram_systemd_attempt _telegram_cron_attempt >/dev/null; \
  _sched_run heartbeat _heartbeat_enable_attempt _heartbeat_systemd_attempt _heartbeat_cron_attempt >/dev/null"
# run again for idempotency
bash -c "source '$SM'; TG_HOME_DIR=/root/tg; WORKSPACE_DIR=/root/ws; LOG_FILE=/tmp/log; \
  _sched_run telegram_jobs _telegram_bootstrap_attempt _telegram_systemd_attempt _telegram_cron_attempt >/dev/null; \
  _sched_run heartbeat _heartbeat_enable_attempt _heartbeat_systemd_attempt _heartbeat_cron_attempt >/dev/null"
CT="$(crontab -l 2>/dev/null)"
l=$(printf '%s\n' "$CT" | grep -c 'run-listener.sh')
dg=$(printf '%s\n' "$CT" | grep -c 'run-digest.sh')
hb=$(printf '%s\n' "$CT" | grep -c 'heartbeat.sh')
fg=$(printf '%s\n' "$CT" | grep -c 'foreign')
blk=$(printf '%s\n' "$CT" | grep -c '>>> qroky-telegram')
if [[ $l -eq 1 && $dg -eq 1 && $hb -eq 1 && $fg -eq 1 && $blk -eq 1 ]]; then
  mark PASS "L2 real crontab: listener+digest+heartbeat once each, idempotent, foreign preserved"
else
  mark FAIL "L2 real crontab l=$l dg=$dg hb=$hb fg=$fg blk=$blk"
fi

# 3) none override degrades (rc 3, no crash)
o="$(QROKY_SCHED_BACKEND=none bash -c "set -e; source '$SM'; TG_HOME_DIR=/root/tg; \
  if _sched_run t _telegram_bootstrap_attempt _telegram_systemd_attempt _telegram_cron_attempt; then echo SCHED; else echo RC=\$?; fi; echo U=\$SCHED_USED")"
echo "$o" | grep -q 'RC=3' && echo "$o" | grep -q 'U=none' && mark PASS "L3 none→rc3, no crash" || mark FAIL "L3 none path: $o"

# 4) bash -n under Linux bash
bash -n "$REPO/distribution/install.sh" && mark PASS "L4 install.sh bash -n OK on Linux" || mark FAIL "L4 bash -n"

# 5) full harness on Linux bash
if QROKY_REPO="$REPO" bash /harness-atom150/atom150-harness.sh >/tmp/h.out 2>&1; then
  mark PASS "L5 full 9-check harness green on Linux ($(grep Totals /tmp/h.out))"
else
  mark FAIL "L5 harness: $(tail -3 /tmp/h.out | tr '\n' '|')"
fi

# clean the container crontab so nothing lingers (container is ephemeral anyway)
crontab -r 2>/dev/null || true
echo "== container totals: fails=$fails =="
exit $fails
