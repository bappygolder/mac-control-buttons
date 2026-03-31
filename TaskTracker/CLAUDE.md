# CLAUDE.md — Local Task Manager (LTM)

This file is loaded automatically when this folder is open as a workspace in Claude Code. Read it before responding to any request.

---

## WHAT THIS IS

The **Local Task Manager (LTM)** is a self-contained, browser-based task tracker. It lives inside larger projects so contributors can track work without needing an external service.

It is **not** part of the macOS app build (`build.sh` only compiles Swift from `Sources/`). This folder is tracked in git as a development companion tool.

---

## FILE MAP

```
TaskTracker/
├── CLAUDE.md              ← you are here (session bootstrap)
├── SKILL.md               ← how to develop and extend the LTM
├── README.md              ← setup + usage guide
├── index.html             ← main app (List + Board views)
├── docs.html              ← documentation viewer
├── resources.html         ← resource index (logos, assets)
├── styles.css             ← all styles for every page
├── task-app.js            ← list + board + detail panel logic
├── docs-app.js            ← docs viewer logic
├── docs-content.js        ← pre-rendered doc content cache
├── project-data.js        ← seed tasks, docs index, areas config
└── resources/             ← design assets (tracked in git, not in build)
    └── README.md          ← how to add/manage resources
```

---

## KEY DESIGN RULES

- **Vanilla JS + HTML/CSS only** — no build step, no npm. Open `index.html` in a browser.
- **Local-first** — all task state lives in `localStorage`. The seed data in `project-data.js` is the git-tracked baseline.
- **Notes field** — `task.notes` is plain text (preview). `task.body` is HTML (rich text from the detail panel editor).
- **Lane system** — `processing` and `on-hold` are separate lane values but display under the same "Processing / On Hold" board column.
- **Board collapse** — collapsed columns are stored in `localStorage` under `ui.collapsedColumns`. They render as vertical strips on the right side of the board.
- **Resources** — files in `resources/` are tracked in git but excluded from any app build process.

---

## ACTIVE LANES

| Lane key | Display label | Active? |
|---|---|---|
| `newly-added-or-updated` | Newly Added or Updated | ✓ |
| `backlog` | Backlog | ✓ |
| `processing` | Processing / On Hold | ✓ |
| `on-hold` | Processing / On Hold | ✓ |
| `in-progress` | In Progress | ✓ |
| `completed` | Completed | — |
| `archived` | Archive | — |

---

## RECOMMENDED MODEL FOR THIS PROJECT

| Task | Model |
|---|---|
| Adding features, refactoring JS | Sonnet 4.6 (`claude-sonnet-4-6`) |
| Architecture decisions, big rewrites | Opus 4.6 (`claude-opus-4-6`) |
| Small edits, CSS tweaks | Haiku 4.5 (`claude-haiku-4-5-20251001`) |

---

## FUTURE: BLOCKNOTE MIGRATION

The notes editor currently uses a styled `contenteditable` div. It is designed to be replaced with **BlockNote** (React-based block editor) in a future migration when this project gets a proper build setup. The editor interface uses `getContent()`/`setContent()`/`onChange()` patterns to keep the swap clean.
