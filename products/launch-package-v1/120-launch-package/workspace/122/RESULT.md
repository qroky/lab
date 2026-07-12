# RESULT — ATOM-122 (handoff message EN/RU/RO + launch checklist)

- **Executor:** sales-operator (voice/outreach), reuse per F2
- **Date:** 12.07.2026
- **Scope:** H5 + H6 of ATOM-120 INPUT.md; per STATUS.md house-map correction all artifacts land in qroky/lab `marketing/` (framework read-only, untouched)

## H5 — Messenger handoff message (three files)

| File | Status |
| :--- | :----- |
| `marketing/handoff/handoff.en.md` | done |
| `marketing/handoff/handoff.ru.md` | done |
| `marketing/handoff/handoff.ro.md` | done |

Point-by-point against H5:
- **Three languages, natively written** — each version composed in its own language from the CEO's style profile (machine-local), not translated under calque; the three texts share the fact skeleton but differ in opener, rhythm, and idiom (RU: «Слушай,» + spoken chain; RO: cleaner front-loaded period, informal «tu»; EN: front-loaded "I've built something and I want your take", no ceremony).
- **2–3 paragraphs each** — exactly 3 short paragraphs per version.
- **What this is** — one plain sentence: open framework turning AI agent work into governed product work; the accountability trail (who formulated / executed / independently verified / what it cost) spelled out in friend-language, not as a slogan.
- **Why the recipient's opinion matters** — honesty as the device (per S2 hint): «версия ранняя — именно поэтому мне нужны твои глаза: понятны ли первые 15 минут человеку, который не я?» (localized in all three).
- **Repo link** — https://github.com/qroky/framework in every version.
- **The mandated line, localized** — RU verbatim «15 минут; сломается — пиши мне»; EN "15 minutes; if something breaks — write me."; RO «15 minute; dacă se strică — scrie-mi.»
- **Forwardability (S3)** — zero context assumed beyond the message: the product is named and explained inside the text, the link is inside the text, and each version ends with an explicit forward invitation; «пиши мне» still resolves sensibly in a forward chain (write the person who sent it to you).
- **Raw-material marking** — every file opens with an HTML comment (outside the forwardable text, above a horizontal rule) stating: draft for the Founder's edit, he sends every copy by hand (S4/S5), forwardable text = below the rule only.
- **Facts used** — only the permitted set: one command, 8 questions, ~3 minutes interview, ≤15 minutes whole path, all local / nothing out without opt-in. No prices, no invented figures, no superlatives.

## H6 — Launch checklist

`marketing/launch-checklist.md` — done. Point-by-point:
- **Soft-launch order** — README merge [CEO] → qroky.com DNS redirect [HUMAN-TASK CEO] → CEO edits handoff → wave 1 (2–3 warm) → feedback loop closes via GitHub issues → waves 2–3, days apart (gated on loop closure, not calendar).
- **Wave counter** — table: волна №, дата, кому, статус фидбека; with a status vocabulary (`отправлено` → `фидбек идёт` → `петля закрыта`).
- **Unfreeze trigger, verbatim** — «после 2–3 волн тёплой раздачи» (HN/Reddit/LinkedIn stay frozen until it fires).
- **Readiness criterion** — release kit closed + ≥1 external user completed install (both boxes before wave 1).
- **Hard rule, verbatim (INFO-024)** — «релиз без changelog не публикуется».

## Not done (by mandate)

- **LinkedIn draft — NOT written**: FROZEN per INFO-031; unfreezes only with the wave trigger.
- **Landing — untouched and unmarkable here**: `products/landing-v0/` did not travel to lab (GATE-032 №5), so the H5 freeze note cannot be placed as a file in lab; recorded here in RESULT instead, per STATUS.md orchestrator correction.

## Perimeter & budget

- Framework (`/Users/ghcernei/Work/rpf`) — read-only throughout; zero edits, zero git operations anywhere (commit is the orchestrator's).
- Spend: well inside the ~100k envelope (single-pass reads of INPUT/STATUS/NARRATIVE, distribution/README.en.md, CHANGELOG head, style profile; no subagents).

## Flags for verify / G2

1. The RU mandated line is embedded verbatim; EN/RO are localizations of it — verify should treat the RU string as the anchor.
2. All three handoff texts are deliberately RAW: G2 expects the CEO to rewrite in his own hand; do not judge them as finished outbound copy (S2 says his voice is the hard bar — after HIS edit).
3. The checklist assigns issue-reply drafting to a "support instance" per INPUT §2; that instance does not exist yet — the checklist states the flow, not a live mechanism.
