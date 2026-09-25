# Getting Started & Project Structure

## 1. Environments & Project Structure

### 1.1 HARD GATE: a source tree is required

Plugin development (scaffold/build/debug) requires a NocoBase **source tree**:

- **CLI-managed Git-source app** — created via `nb init --ui` choosing **Git source install**. Source at `<app-path>/source/` (verify `source/packages/core/` exists).
- **Plain source repo** — `git clone https://github.com/nocobase/nocobase.git`; repo root has `packages/core/`.

Docker / `create-nocobase-app` installs do NOT qualify → STOP and offer the two options above; do not scaffold.

**Command execution directories (CLI-managed apps)**: `nb scaffold plugin`, `nb source dev`, `nb source build`, `nb scaffold migration` run from `<app-path>/source/`; `nb plugin enable/disable`, `nb app upgrade/restart`, `nb plugin import` run from anywhere (env-level).

**Sandbox tip**: if global `nb` cannot locate `nocobase-v1`, prepend `PATH="<app-path>/source/node_modules/.bin:$PATH"`.

### 1.2 Plugin load priority (first match wins)

1. `packages/plugins` — source, dev (highest)
2. `storage/plugins` — uploaded/imported compiled plugins
3. `node_modules` — npm-installed / built-in

### 1.3 Plugin directory template

```
packages/plugins/@my-project/plugin-hello/
├── package.json               # name = plugin identifier
├── index.ts                   # server bridge export
├── client-v2.js / .d.ts       # client build entries (v2)
├── client.js / .d.ts          # legacy v1 entries — ignore
├── server.js / .d.ts          # server build entries
├── dist/                      # build output
├── build.config.ts            # optional bundler overrides
└── src/
    ├── index.ts               # default-export server plugin
    ├── client-v2/             # ALL client code goes here
    │   ├── index.tsx          # export { default } from './plugin';
    │   ├── plugin.tsx         # class extends @nocobase/client-v2 Plugin
    │   ├── client.d.ts
    │   ├── locale.ts          # YOU create (tExpr/useT bound to pkg namespace)
    │   ├── models/            # YOU create (FlowModels)
    │   └── pages/             # YOU create (route/settings pages)
    ├── client/                # LEGACY v1 — do NOT touch
    ├── server/
    │   ├── index.ts
    │   ├── plugin.ts          # class extends @nocobase/server Plugin
    │   ├── collections/       # defineCollection/extendCollection (auto-loaded)
    │   ├── commands/          # custom CLI commands
    │   ├── migrations/        # timestamped upgrade scripts
    │   └── __tests__/         # vitest tests
    └── locale/
        ├── zh-CN.json
        └── en-US.json
```

**The scaffold is minimal** — `locale.ts`, `models/`, `pages/`, `migrations/`, `__tests__/` must be created by you as needed. (`src/client/locale.ts` + `src/client/models/` DO exist but are legacy v1 — do not import from them.)

**Key files to edit**: `src/server/plugin.ts` (server logic), `src/client-v2/plugin.tsx` (client logic), `src/server/collections/*.ts` (tables), `src/client-v2/models/*.tsx` (FlowModels), `src/locale/*.json` (translations).

---

## 2. CLI Command Cheat Sheet

```bash
# --- CLI-managed Git-source app (run in <app-path>/source/ unless noted) ---
nb scaffold plugin @my-project/plugin-hello      # scaffold (thin wrapper of pm create)
nb source dev                                    # dev mode, hot reload
nb source build @my-project/plugin-hello         # build (flags: --cwd --no-dts --sourcemap --verbose)
nb scaffold migration <name> --pkg @my-project/plugin-hello --on afterSync
nb plugin enable @my-project/plugin-hello        # any dir (env-level)
nb plugin disable @my-project/plugin-hello       # any dir
nb plugin import /path/plugin-hello-0.1.0.tgz    # any dir; also accepts URL/npm spec; restart after
nb app upgrade                                   # any dir — runs migrations

# --- Plain source repo (run in repo root) ---
yarn pm create @my-project/plugin-hello
yarn dev
yarn build @my-project/plugin-hello --tar        # build + package → storage/tar/<name>-<version>.tgz
yarn nocobase tar @my-project/plugin-hello       # package an existing build
yarn pm enable|disable|remove @my-project/plugin-hello
yarn nocobase create-migration <name> --pkg=@my-project/plugin-hello --on=afterLoad
yarn nocobase upgrade
yarn test packages/plugins/@my-project/plugin-hello/src/server   # tests
```

Do NOT use `create-plugin`, `generate`, or any other scaffold variant. `nb scaffold plugin`'s only flag is `--force-recreate`; `nb source build` has NO `--tar` flag.

**Plugin Manager UI**: `http://localhost:13000/v/admin/settings/plugin-manager` (note `/v/`).

**Default activation via `.env`** (re-run `nocobase install|upgrade` after editing):
```env
APPEND_PRESET_LOCAL_PLUGINS=@my-project/plugin-hello      # listed, manual enable
APPEND_PRESET_BUILT_IN_PLUGINS=@my-project/plugin-hello   # auto-enabled, cannot disable
```

---
