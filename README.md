# qroky/lab — the public factory

This repository is the full self-construction journal of
[**qroky/framework**](https://github.com/qroky/framework): the framework
built itself under its own rules, and every step of that work is here —
verbatim, append-only, unpolished on purpose.

- [`products/`](products/) — one folder per product, one folder per atom:
  `INPUT.md` → the product → blind `VERDICT.md` → status. The permanent
  work record.
- [`decisions/`](decisions/) — the decision journal: gates, risk
  acceptances, information items. Recorded verbatim at decision time and
  never edited after.
- [`TASKS.md`](TASKS.md) — the human panel of next steps.
- `ATOM-*-LAUNCH.md` — the launch mandates, as the executors received them.
- [`roles/`](roles/) — the working role specs of the factory's agents.

## The two houses

**framework = the product.** Only what is universal for every instance
ships: the constitution, runtime bindings, the installer kit, docs,
knowledge — the exact whitelist is
[`distribution/dist-manifest`](https://github.com/qroky/framework/blob/main/distribution/dist-manifest)
there, and the installer's sparse vendoring plus the freeze check
(`distribution/verify.sh`) enforce it. **lab = the factory.** All the work
that produced the product lives here and never reaches a user's machine.
**Instances stay private** — a founder's workspace belongs to the founder.

## How work flows after the separation (going forward)

- A change to the PRODUCT (constitution, runtime, kit, docs) is
  implemented in framework; the decision that ordered it, the atom records
  that produced it, and the verdict that accepted it are written HERE.
- A lab decision that lands in the product names the framework commit/tag
  once it ships; a framework CHANGELOG entry points back at the release's
  verified records here.
- Nothing here is retouched for appearance. If a record looks rough, that
  is what governed work looks like from inside.

## Приватный слой (owner's revision, GATE-032)

One deliberate exception to "never edited after": before publication the
owner reviewed the journal and moved a private commercial layer out of this
copy (`decisions/GATE-032`). Removed or anonymized: the accelerator
partner's name (now «партнёр-акселератор (MD)» / "accelerator partner
(MD)"), the pricing model with numbers, deal terms and red lines
(`business-strategy-v1`: STRATEGY, pricing/, channel-comparison,
segment-map, pilot-design, NOT-DOING — tombstones remain in place), the
founder's bank-network notes, landing-v0 drafts (personal email / legal
entity), third-party names from the trademark screen, dollar equivalents
of token spend (token numbers themselves are public by design), machine
paths, and references to the owner's neighbouring private projects. Every
removed passage is marked in place with
«[приватный слой — ревизия владельца, GATE-032]» — nothing is silently
missing.

History note: framework's own git history before the separation still
contains this journal (published tags v0.1.2 … v0.3.2 stand on it and are
never rewritten); from the separation commit onward, framework HEAD is the
product only, and this repository is where the journal continues.
