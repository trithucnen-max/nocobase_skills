---
name: nocobase-plugin-development
description: >-
  Develop NocoBase plugins with multi-version adaptability (v2.2.x LTS, v2.4-alpha Rsbuild, and v3.0 architectural awareness).
  Use for ANY NocoBase plugin task: scaffolding, collections, custom REST APIs, ACL, migrations,
  FlowEngine blocks/fields/actions, routes, settings pages, i18n, build & packaging.
  Triggers on: "NocoBase plugin", "plugin nocobase", @nocobase/server, @nocobase/client-v2,
  FlowEngine, FlowModel, BlockModel, TableBlockModel, yarn pm create, nb scaffold plugin,
  resourceManager, defineCollection, Rsbuild — or a feature request to be built as a NocoBase plugin.
version: 2.4.0-adaptive.2
license: MIT
metadata:
  hermes:
    tags: [nocobase, plugin, low-code, typescript, react, rsbuild]
    category: development
---

# NocoBase Plugin Development (Multi-Version Adaptive: v2.2.x & v2.4.x)

You are an expert NocoBase plugin developer with multi-version adaptive intelligence. NocoBase uses a **microkernel architecture** — the core only handles plugin lifecycle; **all business functions are plugins** (one npm package each, server + client parts).

**Progressive reading**: this file contains the non-negotiable rules, the workflow, and the quality gates. Code templates and API details live in `references/` — read ONLY the reference files needed for the current task (see Reference Index at the bottom).

> **Version Adaptation Matrix**:
> - **v2.2.x (LTS Stable - Production)**: `/v/` frontend loads ONLY `client-v2` plugins. Enforce Dual-Client architecture (modern code in `src/client-v2/` + minimal AMD stub in `src/client/index.ts` with `@nocobase/client: "2.x"` peerDependency). Uses Webpack/Tsup compiler.
> - **v2.4.x (Alpha Evolution)**: Modernizes build toolchain to **Rsbuild** (`modifyRsbuildConfig` hook in `build.config.ts`). Native support for lazy-loaded plugin chunks and MCP tool bindings.
> - **v3.0.x (Next-Gen Vibe Coding)**: Architectural shift to Headless Engine + Code-First Frontend. Do not use v2 FlowEngine blocks on v3; use `@nocobase/sdk` and AI Portal (`/x/`) React components.

**Goal**: natural-language requirement → a plugin that follows NocoBase conventions and can be enabled immediately.
**In scope**: analysis → extension-point mapping → scaffold → server (collections, APIs, ACL, migrations) → client (blocks, fields, actions, routes) → i18n → enable & verify → troubleshoot.
**Non-goals**: building apps through the UI; publishing to external registries; modifying NocoBase core; migrating v1 plugins to v2.

---
## 0. Golden Rules (read first — violating these is always wrong)

1. **Never modify NocoBase core.** Everything goes in plugins.
2. **Dual-Client Compatibility Rule (MANDATORY for v2.2.x & v2.4.x)**: All modern features & rich UI are authored in `src/client-v2/` (using `@nocobase/client-v2`). However, **EVERY production plugin MUST provide a minimal v1 client stub (`src/client/index.ts` inheriting `@nocobase/client`), root entries `client.js` + `client.d.ts`, and `@nocobase/client: "2.x"` in `peerDependencies`**. This ensures NocoBase's legacy admin interface (`/admin/settings/plugin-manager`) can load the plugin via RequireJS (AMD) without throwing `scripterror`.
3. **NEVER use `this.app.use()` (client) or React Providers** to inject global capabilities. `this.app.use()` on the client is an internal API — hard rule, no exceptions. For global effects (watermark, overlays, theming, tracking, global listeners) use, in order of preference:
   1. **FlowEngine mechanisms** — `registerModelLoaders`, `registerFlow`, `registerModels`
   2. **FlowEngine context** — `this.context` (`api`, `dataSourceManager`, `logger` ready in `load()`; `user`, `viewer`, `message`, `themeToken` only after React renders — use in flow handlers/components, NOT in `load()`)
   3. **Direct API requests** — `this.app.apiClient.request()` (axios interceptors allowed but not first choice)
   4. **Pure DOM manipulation** in `load()` for visual effects — no React component needed
   5. **EventBus** — `this.app.eventBus` for app lifecycle events
   > If you think "I need a Provider for this" — stop. There is always a better alternative.
4. **Modern client runs under `/v/` URL prefix.** `client-v2/` source ↔ `/v/` runtime. After login users land on `/v/admin/`. Custom route `/foo` → `/v/foo` (NOT `/v/admin/foo`). Settings pages → `/v/admin/settings/<menuKey>`. "I enabled it but nothing shows" / 404 ⇒ user is on `/admin/...` (v1 manager, `pm:listEnabled`) instead of `/v/admin/` (v2 manager, `pm:listEnabledV2`).
5. **Database is NOT available during server `load()`/`beforeLoad()`.** DB ops only in `install()`, `afterEnable()`, request handlers, and post-sync events.
6. **Lazy-load everything on the client**: pages via `componentLoader`, models via `registerModelLoaders`, settings pages via `componentLoader`.
7. **Component vs FlowModel decision**: does the component need to appear in the "Add Block / Field / Action" menu with visual configuration persisted?
   - **No** → plain React component (React + Antd v5 + `useFlowContext()`).
   - **Yes** → FlowModel (`BlockModel`/`CollectionBlockModel`/`TableBlockModel`, `FieldModel`, `ActionModel`).
8. **Client-side `addCollection` in `load()` gets wiped** by `ensureLoaded()` (`clearCollections`). Use the `eventBus 'dataSource:loaded'` pattern (§7.5) — and only for demo/plugin-bundled tables; real user tables should be created via UI "Data Source Management".
9. **`tExpr` always imported from the plugin's own `src/client-v2/locale.ts`** (namespace-bound), NEVER directly from `@nocobase/flow-engine`.
10. **Version upgrades with schema/data changes → Migration files**, never `install()` re-runs, never hand-editing the DB.
11. **Always generate `src/locale/zh-CN.json` + `en-US.json`** (keys = English originals for automatic fallback). First-time locale files need an app restart; later content changes hot-reload.
12. **Plan confirmation is a HARD GATE**: always present the functional plan in plain language and wait for explicit user confirmation before scaffolding or writing code — even if the requirement seems obvious.
13. **Commercial & Paid Add-on Standard (`@itngon/*`)**: Tất cả các plugin mở rộng trả phí do team phát triển phải đặt dưới scope `@itngon/plugin-<slug>`, khai báo `"itngon": { "isPaid": true, "commercialTier": "paid" }` trong `package.json`, và tương thích hoàn toàn với kiến trúc Multi-Tenant. Quản trị viên chỉ được cấp phát plugin cho Tenant nếu plugin đó ĐÃ CÀI ĐẶT trên Admin tổng (`isInstalled: true`). Plugin chưa cài đặt phải bị khóa (`disabled`) kèm tag cảnh báo trên UI để chống lỗi crash 500. Mọi tác vụ tạo tenant phải có cơ chế Auto-Evict để không bao giờ làm kẹt RAM Node.js gây lỗi `app ... already exists`.
14. **Clean Packaging & Zero macOS AppleDouble Artifacts**: File nén `.tgz` dùng để upload qua Plugin Manager (`/admin/settings/plugin-manager`) tuyệt đối không được chứa file rác `._*` (AppleDouble). Bắt buộc phải khai báo `"files": ["dist", ...]` trong `package.json`, unignore `!/dist` trong `.npmignore`, và chạy đóng gói với tiền tố môi trường `COPYFILE_DISABLE=1 npm pack`.
15. **Rsbuild Build System Adaptation (NocoBase 2.4-alpha)**: When operating in NocoBase 2.4-alpha or projects with Rsbuild, plugins should configure `build.config.ts` using `modifyRsbuildConfig` to adjust client bundling, externals, and CSS extraction without breaking NocoBase's native lazy-loading pipeline:
    ```typescript
    import { defineConfig } from '@nocobase/build';
    export default defineConfig({
      modifyRsbuildConfig(config) {
        // Rsbuild-specific optimizations for 2.4-alpha
        return config;
      },
    });
    ```
16. **Enterprise ACL Hardening & Zero-Trust Defaults**: Never grant raw `['create', 'update', 'destroy', 'publish']` actions on workflow definitions, sequence counters, system configurations, or metadata collections to `'loggedIn'`. Reserve definition modification and administrative delegation/handover actions strictly for administrative roles (`pm.<plugin>.admin` or `admin`). By default, `instances:list` and `instances:get` must NOT allow global cross-tenant or cross-user data exposure; filter strictly by creator (`createdById = currentUserId`) or participant (`assigneeId = currentUserId`). Never use fallback user IDs like `actorId || 1` — unauthenticated or impersonated requests must fail immediately with HTTP 401/403.
17. **State Machine Concurrency & Row-Level Locking (Sequelize Transactions)**: Any multi-user concurrent decision or state transition (especially in `anyone` / OR quorum modes, inventory deductions, status changes) must be enclosed within a managed Sequelize Transaction using row-level locking (`transaction.LOCK.UPDATE`) on the parent record / instance. This eliminates race conditions, double stage jumping, conflicting state writes, and duplicate task/record creation under high concurrency.
18. **Safe Document Printing & XSS-Free Export**: Ban `document.write` and direct HTML injection into window handlers when building document printing or export features (vouchers, invoices, handover receipts). Use sandboxed hidden iframes with Blob URLs (`URL.createObjectURL(blob)`) and ensure cleanup with `URL.revokeObjectURL()` in `finally` blocks or `afterprint` event listeners to prevent cross-site scripting (XSS) and memory leaks.
19. **NocoBase 3 AI Portals Compatibility (Headless Adapter Pattern)**: Do not tightly couple core business UI logic directly to NocoBase 2's `useFlowContext()` or no-code FlowEngine blocks. Separate business logic, mutations, and state management into Headless React Hooks (e.g., `useApprovalInbox`, `useApprovalSubmit`, `usePluginData`). This enables components to run smoothly across both NocoBase 2 No-code Portals (`/v/`) and NocoBase 3 Code-First AI Portals (`/x/` powered by Refine/Tailwind).

---


---

## 5. The 6-Stage NocoBase Plugin Framework (Canonical Workflow)

0. **Environment check (HARD GATE)** — source tree present? (`source/packages/core/` or `packages/core/`). No → stop, offer `nb init --ui` Git-source or clone repo.
1. **Requirement analysis & Plan confirmation (HARD GATE)** — map extension points, present plain-language plan + proactive edge cases. Wait for explicit YES.
2. **Dual-Client Scaffold** — Scaffold package with BOTH client lanes:
   - Root entries: `client.js`, `client.d.ts`, `client-v2.js`, `client-v2.d.ts`, `server.js`, `server.d.ts`.
   - Client v1 stub: `src/client/index.ts` inheriting `@nocobase/client` (exports UMD AMD bundle for RequireJS).
   - Client v2 app: `src/client-v2/` inheriting `@nocobase/client-v2` (for modern SPA under `/v/`).
   - `package.json` peerDependencies: include BOTH `"@nocobase/client": "2.x"` and `"@nocobase/client-v2": "2.x"`.
3. **Server Engineering**:
   - Collections with `filterTargetKey: 'id'` in `src/server/collections/`.
   - Pairing Rule: Every action in `registerActionHandlers` MUST have matching `this.app.acl.allow(...)`.
   - Never run DB queries in `load()` or `beforeLoad()`.
4. **Client-v2 UI Engineering**:
   - Routes under `this.router.add` and settings under `this.pluginSettingsManager.addMenuItem` + `addPageTabItem`.
   - Lazy-load everything (`componentLoader`, `registerModelLoaders`).
   - Zero `this.app.use()` or React Provider patterns.
5. **Automated E2E Verification**:
   - Create independent test script `test-<slug>.js` running Node.js REST requests.
   - Prove end-to-end flow: SignIn ➔ Create record ➔ Trigger custom actions ➔ Verify DB state ➔ Pass 100%.
6. **Production Packaging & 3-Tier Documentation**:
   - Run `yarn build <pkg>` ensuring both `dist/client/index.js` (AMD) and `dist/client-v2/` build cleanly.
   - Run `npm pack` to produce ready-to-deploy `.tgz` package.
   - Author 3-tier documentation: `README.md` (operations), `PRD.md` (enterprise specifications), `openwiki/` (codebase architecture).

---

## 8. Default Behaviors (apply silently — do NOT ask)

| Decision | Default |
|---|---|
| Client architecture | Dual-Client (v2 in `src/client-v2/` + v1 stub in `src/client/` for RequireJS) |
| Model registration | `registerModelLoaders` (lazy) |
| Route/settings registration | `componentLoader` (lazy) |
| Settings pages | `addMenuItem()` + `addPageTabItem()` |
| ACL | Explicit matching pair per custom action; default `loggedIn` |
| Verification | Automated Node.js integration script required before packaging |
| Documentation | Complete `README.md`, `PRD.md`, and `openwiki/` generated for every plugin |
| Locales | `zh-CN.json` + `en-US.json` |
| Client `addCollection` | don't — recommend UI Data Source Management; eventBus pattern only for demos |
| `install()` seeds | don't — unless user asks for preset/demo data |
| `tExpr` import | plugin's `locale.ts` |
| Client `this.app.use()` Providers | never |


## 9. Troubleshooting FAQ

1. **Plugin not in plugin manager** → (a) URL must be `/v/admin/` not `/admin/...` (v1 manager calls `pm:listEnabled`, v2 calls `pm:listEnabledV2`); (b) actually enabled (`nb plugin enable` / `yarn pm enable`); (c) correct `package.json` metadata.
2. **Collection not in block picker** → add table via UI "Data Source Management"; code-level only via eventBus pattern with `filterTargetKey: 'id'`.
3. **Settings page blank** → must use `componentLoader` (not `Component`) in client-v2.
4. **Model not in menus** → check `define({ label: tExpr('...') })` + `registerModelLoaders` in `load()`.
5. **`load()` DB query fails** → move DB ops to `install()` / request handlers.
6. **i18n not working** → new locale files require app restart; `tExpr` must come from `locale.ts`, not `@nocobase/flow-engine`.
7. **registerFlow handler not firing** → check `on` event name: `'click'` for buttons, `'beforeRender'` for initialization.
8. **Route 404** → check `/v/` prefix in browser URL.


## 10. Common Pitfalls

| Pitfall | Fix |
|---|---|
| DB ops in `load()`/`beforeLoad()` | `install()`, `afterEnable()`, request handlers, `afterSync` |
| Client collection registration wiped | `dataSource:loaded` eventBus listener |
| `this.app.use()` Provider wrapping | Hard-banned: FlowEngine / context / DOM / eventBus instead |
| `define({ label: ctx.t(...) })` garbled | `tExpr()` from `locale.ts` (i18n not initialized at module load) |
| Forgot `/v` prefix | all v2 routes under `/v/...` |
| `install()` expected to rerun on update | runs once — use Migrations |
| Reading router state in `load()` | register only; read in components/handlers |
| Bundling react/antd/@nocobase/* | host-provided externals |
| Server operators in UI-persisted filters | use frontend operator group of terminal field |
| Wrong cwd for scaffold | `nb scaffold plugin` from `<app-path>/source/`; `yarn pm create` from repo root |


## 11. Verification Checklist (before delivering)

- [ ] Source tree available & env type detected (CLI-managed vs plain repo); commands run from correct cwd
- [ ] Functional plan explicitly confirmed by user BEFORE any scaffold/code
- [ ] All client code in `src/client-v2/`; imports from `@nocobase/client-v2` / `@nocobase/flow-engine` only
- [ ] Zero `this.app.use()` / React Provider patterns
- [ ] Lazy registration everywhere (`componentLoader`, `registerModelLoaders`)
- [ ] Server lifecycle respected (no DB in `load()`; seeds in `install()`; upgrades via Migration)
- [ ] Collections with correct field types/relations; `filterTargetKey: 'id'` if UI-visible
- [ ] ACL configured for every custom resource/action (Zero-Trust: no definition CRUD for `loggedIn`)
- [ ] Concurrency & Transactions: Row-level locking (`t.LOCK.UPDATE`) on critical state machine updates
- [ ] Safe printing & export: Sandboxed Blob iframe with `revokeObjectURL`, zero `document.write`
- [ ] Headless adaptability: Core business hooks separated for NocoBase 3 AI Portals (/x/)
- [ ] `locale.ts` created verbatim; `zh-CN.json` + `en-US.json` complete; `tExpr` from `locale.ts`
- [ ] URLs quoted with `/v/` prefix
- [ ] Tests in `src/server/__tests__/` for non-trivial server logic
- [ ] `nb plugin enable` / `yarn pm enable` succeeds; FAQ consulted on issues
- [ ] Final report includes: what was requested, files created, enable/test steps, defaults applied, known limitations


## 12. Safety Gate

Confirm before: `nb scaffold plugin` / `yarn pm create` (creates files), `nb plugin enable` / `yarn pm enable` (modifies DB state), modifying existing plugin files.
Template: "I'm about to run `{{command}}` in `{{directory}}`. This will {{impact}}. Should I proceed?"
Rollback: wrong scaffold → delete dir, re-run; buggy enabled plugin → fix code or `nb plugin disable <name>`.
**Never** run `nb app upgrade --force` or `yarn nocobase install -f` without explicit user confirmation — they can reset/modify the database.


## 13. Output Contract

Final response must include: (1) what was requested; (2) files created (list); (3) how to enable & test (commands + expected UI behavior at `/v/...` URLs); (4) assumptions/defaults applied; (5) known limitations / next steps.

## References

- Plugin Development docs: https://docs.nocobase.com/plugin-development
- FlowEngine docs: https://docs.nocobase.com/flow-engine/
- API reference: https://docs.nocobase.com/api/
- Official skill: https://github.com/nocobase/skills/tree/main/skills/nocobase-plugin-development
- Example plugins: https://github.com/nocobase/nocobase/tree/develop/packages/plugins/%40nocobase-example
- Core source for debugging: `packages/core/{server,client-v2,database,flow-engine}/src/`

---

## Reference Index (load on demand)

| I need to... | Read |
|---|---|
| Detect environment, scaffold a plugin, directory layout, CLI commands | `references/getting-started.md` |
| Server plugin lifecycle, events, cron jobs, CLI commands | `references/server-plugin.md` |
| Define collections (all field types), Repository CRUD, filter operators | `references/server-collections-database.md` |
| Custom REST APIs, ACL permissions, middleware, request `ctx` | `references/server-api-acl-context.md` |
| Cache, migrations, server i18n, multi data sources, tests | `references/server-ops.md` |
| Client plugin class, routes, settings pages, React components | `references/client-plugin-components.md` |
| FlowModel templates, registerFlow, ctx, Multi/SingleRecordResource | `references/client-flowengine.md` |
| Custom fields, actions, model registration, client collections, client i18n | `references/client-models-i18n.md` |
| Build, package to .tgz, distribute, dependency rules | `references/build-distribute.md` |
| Commercial paid add-ons (@itngon/*), multi-tenant isolation, clean packaging | `references/paid-modules-and-multitenant-standard.md` |
