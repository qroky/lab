# narrative-notes — ATOM-150 (windows-path-v1)

- The reconnaissance held: v1 was never a port, it was an **abstraction**. The kit already
  degraded honestly without launchd (the `command -v launchctl` guards), so the honest move was
  to build a scheduler layer *around* those exact points and let launchd stay the literal old path
  — Windows becomes first-class by *addition*, not rewrite.
- The sharpest constraint — "the second wave-1 recipient is on a Mac, his path can't move a byte"
  — turned into the design's spine: launchd detected first, its bootstrap functions called verbatim,
  and a cmp proof (plist heredocs + launchctl-calling functions byte-identical) rather than a promise.
- Honesty scaled down as well as up: with no live systemd bus in the container, the systemd backend
  is *simulated* and RESULT says so plainly — the real Linux proof is the cron path and autodetection.
  The living Windows install remains the validation, exactly as INFO-035 framed it.
- One small dividend of past discipline: ATOM-131's launcher was already shell-agnostic, so H2's
  "PATH block for bash profiles" needed zero new code — a reminder that a clean earlier atom pays
  the next one's rent.
- The scheduler-absence message is the product's manners in miniature (INFO-044): not "no launchctl
  here", but "no scheduler — here is the exact WSL2 fix, and here is docs/WINDOWS.md". Decide, don't hint.
