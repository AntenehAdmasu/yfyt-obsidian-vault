# YFYT Obsidian vault

Personal thinking vault for product notes, decisions, and research. Markdown-first; intended for use with [Obsidian](https://obsidian.md/) and optional Git sync (for example the Obsidian Git community plugin).

## Layout

| Folder | Purpose |
|--------|---------|
| `00-inbox/` | Quick captures and rough notes |
| `10-product/` | Vision, scope, pitfalls, users |
| `20-features/` | One note per feature idea |
| `30-decisions/` | Dated decision records |
| `40-research/` | Research and references |
| `50-meta/` | Glossary, open questions |

Starter notes live under `10-product/` and `50-meta/`. See `YFYT-Obsidian-Claude-Setup.pdf` in this repo for the full setup checklist (plugins, Claude Code, workflow).

## Remote

Canonical repo: [AntenehAdmasu/yfyt-obsidian-vault](https://github.com/AntenehAdmasu/yfyt-obsidian-vault) (`yfyt-obsidian-vault` on GitHub).

## First push (from this folder on your Mac)

This environment cannot run `git` for you; run once in **Terminal** (avoid iCloud/Dropbox-only sync for the vault if you use Git):

```bash
cd "/Users/antenehadmasu/Projects/Obsidian Vault/YFYT"
./scripts/first-push.sh https://github.com/AntenehAdmasu/yfyt-obsidian-vault.git
```

SSH works too:

```bash
./scripts/first-push.sh git@github.com:AntenehAdmasu/yfyt-obsidian-vault.git
```

The repo should be **empty** before the first push (no README on GitHub yet), or follow GitHub’s merge instructions if you already committed there.

## Clone on another machine

```bash
git clone https://github.com/AntenehAdmasu/yfyt-obsidian-vault.git YFYT
cd YFYT
```

Open the folder as an Obsidian vault (**Open folder as vault**).

## Git notes

- `.obsidian/workspace*` is ignored so layout/layout state does not churn in commits.
- `.trash/` is ignored.
- Do not rely on iCloud/Dropbox for vault sync alongside Git; use one sync strategy to avoid conflicts.

## License

Set the license on GitHub to match how you want notes shared; this README does not grant rights by itself.
