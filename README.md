# YFYT Obsidian Vault

Personal thinking vault for product notes, decisions, and research. Markdown-first; intended for use with [Obsidian](https://obsidian.md/) and Git sync.

## Directory structure

| Folder | What goes here | Examples |
|--------|---------------|----------|
| `00-inbox/` | Quick captures and rough notes. Triage into the right folder later. | Half-formed ideas, screenshots, links to read |
| `10-product/` | Product-level thinking: vision, scope, users, risks. | [[vision]], [[scope]], [[users]], [[pitfalls]] |
| `20-features/` | One note per feature or system. Design, status, open questions. | [[wingman-signal-generation]], [[risk-engine]], [[database-schema]], [[market-data]], [[parking-lot]] |
| `30-decisions/` | Dated decision records. Once something is decided, it lives here. | [[2026-04-16-model-locked]], [[2026-04-18-trading-targets]], [[2026-04-16-build-rhythm]] |
| `40-research/` | Research, analysis, competitive intel, cost breakdowns. | [[tech-stack]], [[competitive-landscape]], [[api-cost-analysis]] |
| `50-meta/` | Glossary, open questions, vault conventions. | [[glossary]], [[open-questions]] |
| `60-contexts/` | Session context files — point-in-time snapshots of what was built and decided. Not current state; tracks evolution. See [[about-contexts]]. | [[context-april-14-2026]], [[context-april-18-2026]] |

## How to use this vault

- **Current state** lives in `10-product/` (vision, scope, users) and `20-features/` (what's being built)
- **Why we decided X** lives in `30-decisions/` — check here before re-debating a settled question
- **Research and analysis** lives in `40-research/` — cost models, competitive positioning, tech stack
- **Unresolved questions** live in `50-meta/open-questions.md` — promote answers to `30-decisions/` when decided
- **Session history** lives in `60-contexts/` — read [[about-contexts]] for how these work
- **Out-of-scope temptations** go in `20-features/parking-lot.md` — never lost, never allowed to derail current phase

## Conventions

- Use `[[wikilinks]]` to connect notes — Obsidian builds a graph from these
- Decisions are dated: `YYYY-MM-DD-short-name.md`
- Context files are dated by session: `context-april-18-2026.md`
- Don't duplicate content — link to the source note instead
- Keep notes concise — detail belongs in the code repo, thinking belongs here

## Remote

Canonical repo: [AntenehAdmasu/yfyt-obsidian-vault](https://github.com/AntenehAdmasu/yfyt-obsidian-vault)

## Git notes

- `.obsidian/workspace*` is ignored so layout state doesn't churn in commits
- `.trash/` is ignored
- Do not use iCloud/Dropbox for vault sync alongside Git — pick one strategy
