# RESULT — ATOM-121 (README + FAQ + UPDATES + CONTRIBUTING + CHANGELOG alignment)

- atom: ATOM-121 (child of ATOM-120)
- delivered: 2026-07-12
- branch: `atom-120-launch-package` in qroky/framework working copy (/Users/ghcernei/Work/rpf), NOT pushed (G2/publication = HUMAN-TASK CEO)
- spend: ~95k tokens (well inside the ~230k envelope)

## Files delivered

| File | Status |
| :--- | :--- |
| `/Users/ghcernei/Work/rpf/README.md` | rewritten (EN-only storefront) |
| `/Users/ghcernei/Work/rpf/docs/REPO-GUIDE.md` | new — old navigator preserved |
| `/Users/ghcernei/Work/rpf/docs/UPDATES.md` | new — user updates page |
| `/Users/ghcernei/Work/rpf/CONTRIBUTING.md` | new — BDFL + forking policy |
| `/Users/ghcernei/Work/rpf/distribution/dist-manifest` | +1 line: `CONTRIBUTING.md` |
| `/Users/ghcernei/Work/rpf/CHANGELOG.md` | untouched — consistency checked, no edits needed |

## Self-report per H-item (my scope)

**H1 (amended INFO-043) — README.md.** Hero paragraph 1 carries the formula
VERBATIM («Qroky turns agent work into governed, verified, auditable product
work»), the autonomy line (state a task → come back to a finished result),
«governed work system, not a coding harness», and the founders/regulated
year-one focus (NOT-DOING «framework for everyone» honored). Governance =
seat belt is strictly paragraph 2 and carries the accountability contour as
THE canonical value description (who formulated / who executed / who
blind-verified / where the human risk acceptance / what was spent / what was
delivered). First screen = the Codex five points in order: 15-minutes → how
to install → what appears after «qroky start» → what stays local → how it
works. Install command = the REAL v0.4.1 entry
(`bash <(curl -fsSL https://raw.githubusercontent.com/qroky/framework/main/qroky.sh) install`),
verified against qroky.sh header, CHANGELOG v0.4.1, distribution/README.en.md;
git clone stated as the air-gapped alternative. «What you do / what the
system does» = the three human products verbatim in spirit (missing
information, risk acceptance, intent at gates). Skeptic FAQ: whose keys and
data; what leaves the machine (nothing without opt-in, closed list linked);
real monthly cost (token numbers only — see cost note below); vs bare
Claude; known v1 limits (MANIFEST four + macOS-launchd honesty + reference
runtime). Verbatim lines all present (grep-checked, one occurrence each):
language line, self-update line (ONE line, in the «What's in the box»
features list, no section — depth in docs/UPDATES.md), disclaimer line,
«what if the project/author disappears», backup line (twice: §What stays
local + FAQ). Early-access block: built in the open, issues welcome, direct
link to https://github.com/qroky/framework/issues as THE feedback channel,
plus the qroky/lab link.

**Cost note (H1 FAQ, §3.4 no-invented-figures).** The only $-figures in the
accessible record are contested: the $8.00/M rate was BLOCKED by the
token-economics lens (074-lens LENS-VERDICT F1: placeholder, ~3.2× likely
blended rate) with the instruction «do not publish cost lines to founders
until real contracted rate is confirmed». Per mandate, the FAQ therefore
publishes measured TOKEN numbers with links (typical atom ~178k — worked
example 177,951 in lab 072-telemetry-showcase/showcase/example-cost-line.txt;
largest tree ~2.76M / 21 agents — lab 007 RESULT.md) and marks the «typical
user month» explicitly as a placeholder until first external users produce it.

**H2 — navigator.** Old README's navigation content (Quickstart reading
order + Repository map table + the product/lab paragraph) preserved
content-identical at `docs/REPO-GUIDE.md`; the ONLY textual change is
relative-link prefixes (`../`) required by the new location, plus a one-line
provenance header. Note: the preserved table says «four normative documents»
while framework/ holds five files (SYNTHESIS-PROTOCOL.md) — pre-existing
wording, preserved as-is per content-identical rule; flagged for a future
touch, not fixed here.

**H3 — hero grep.** Hero (title + paragraph 1) contains audit/journal/verify
ONLY inside the mandated verbatim formula («verified, auditable»). See
E7-flag below.

**H4 — claims to artifacts.** Every factual claim links to a real artifact:
8 questions / 15 min / opt-in list / backup → distribution/README.en.md;
self-built constitution → MANIFEST.md + qroky/lab; 21 agents / 7 roles /
~2.76M → lab products/pilot-prerequisites-v1/007-pilot-prerequisites/RESULT.md;
calibration 8×→1.8×→6% → knowledge/precedent/verify-envelope-calibration.md;
decision journal → lab decisions/; OpenAI convergence → lab
decisions/INFO-039-openai-harness-lessons.md; typical-atom tokens → lab
072 showcase example-cost-line.txt. All lab URLs use
https://github.com/qroky/lab/... (public per bd42896/GATE-032). One
placeholder (user-month cost) is explicitly marked as placeholder. No
invented quotes/logos/market figures. All relative links machine-checked
against the tree (zero broken).

**H8 — docs/UPDATES.md.** Full mechanics verified against real code
(install.sh cmd_check_update/cmd_show_update_details/cmd_apply_update lines
1555–1679, _write_heartbeat_files lines 1113–1163, qroky.sh dispatch):
heartbeat (launchd Mon–Fri 09:07) → read-only `--check-update` → release
tags only (`v*`), never main → 3-line digest + `.qroky/update-available`
marker → explicit «да» via `qroky update` → decision record
`decisions/UPDATE-YYYY-MM-DD-vX.Y.Z.md` in the USER's decisions/ (mini-atom).
Local-edit fate: conflicts SHOWN before confirm, stash + re-apply, failure
path names `git stash list` — documented as coded. Manual path: `qroky
update` / `qroky details` + air-gapped `bash install.sh --check-update /
--show-update-details / --apply-update`. Rollback: `git -C <ws>/framework
checkout <tag>` with an honest note that install-state re-syncs on next
update (no rollback FLAG exists in the code — documented the real mechanism,
invented no command). Full disable: launchctl bootout + rm of the heartbeat
plist (exact commands), or never say yes at Q7; re-enable `qroky
enable-heartbeat`. The right «не трогайте мой инстанс» stated EXPLICITLY.
Identity guarantee (INFO-028 п.4): core never silently modified, every state
recoverable via git history, user's decisions/ = the instance's own journal.

**H10 — CONTRIBUTING.md.** BDFL (owner decides what enters the core);
issues/PR = candidates in the touch queue, the external door into the SAME
constitutional cycle (formulate → execute → blind-verify → recorded gate),
never around it; forking explicitly WELCOMED; trademark line verbatim in
spirit: code Apache-2.0 free, the name Qroky protected — forks rename;
multi-platform ports via forks/bindings per runtime/INTERFACE.md (file
exists — link verified, its «See CONTRIBUTING for the forking policy» line
now resolves to a real file).

**H9 — CHANGELOG.md.** Checked, not rewritten: v0.4.1 entry's install
command and `qroky` command claims match the new README verbatim; no
inconsistencies found; zero edits. (The launch-package changes themselves
will be rendered into the changelog at their release freeze — not composed
here, per the INFO-016 anti-rationalization discipline.)

**H11 (a,b + INFO-039 к.26).** (a) «What you get in 15 minutes» is the first
section; philosophy («How it works») is fifth. (b) No internals before the
install command — sections 1–2 are outcome/command only. Vocabulary line
«agent harness / harness engineering» + one OpenAI-convergence line present
in «How it works», linked to INFO-039. (c)–(e) are kit-text audits outside
my file scope (installer strings untouched — INFO-035 clean-run preserved).

**dist-manifest.** Manifest lists root files by name → added one line
`CONTRIBUTING.md` (mandate's condition met). docs/ ships whole as `docs/`
pattern → UPDATES.md and REPO-GUIDE.md ride the existing pattern, no manifest
change needed. `bash distribution/verify.sh .` run: my files pass; only
offenders are untracked local `.DS_Store` junk (pre-existing, not committed).

## Flags

- **E7-FLAG (H1-amended vs H3):** H1 (amended per INFO-043) requires the
  formula VERBATIM in the hero — and the formula contains «verified,
  auditable». H3 (unamended) demands the hero contain none of
  audit/journal/verify; a substring grep for «audit» matches «auditable».
  Not resolvable at my level without reopening a closed decision. Resolution
  APPLIED (not decided): lex posterior — the later INFO-043 amendment wins;
  H3 read as whole-word grep (no standalone audit/journal/verify in hero;
  machine-checked). Verify/CEO should confirm this reading.
- **Finding (not fixed, out of scope):** MANIFEST.md still links
  `decisions/RISK-002-open-core-boundary.md` and `decisions/` as local paths
  — broken since SEPARATION moved decisions/ to the lab. README's old text
  had the same class of issue (its RISK-002 mention already said «in the
  lab»). Candidate for the touch queue.
- **Finding (preserved, not fixed):** REPO-GUIDE «four normative documents»
  vs five files in framework/ — see H2 note.

## Commits (local, branch atom-120-launch-package, NOT pushed)

See final report / git log; two commits, format `feat: …`.
