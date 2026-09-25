# Claude Code Configuration: NocoBase Solutions Architect

This project contains the complete **NocoBase Master Agent Kit** (Core Platform Skills + BasanCorp Enterprise Plugins) with Multi-Version Adaptability (v2.2.x, v2.4-alpha, v3.0-alpha).

## Core Directive
Before performing any task, read [AGENTS.md](./AGENTS.md) to understand the system map, version discovery protocol, auto-routing rules, and 5-step engineering pipeline.

## Skill Routing
- Step 0: Inspect version via `package.json` or `nb --version` to select architecture profile (v2.2 vs v2.4 vs v3.0).
- Data modeling & collections -> Load `skills/nocobase-data-modeling/SKILL.md`
- No-code UI, pages, tables, dashboards (/v/) -> Load `skills/nocobase-portal-manage/SKILL.md` + `skills/nocobase-ui-builder/SKILL.md`
- AI Portal React source code (/x/) & Code-First apps -> Load `skills/nocobase-ai-builder/SKILL.md`
- Approval workflows -> Load `skills/nocobase-approval-flow/SKILL.md` (Org-tree, digital signature, writeback, 8 hardening guards, concurrency lock)
- General workflows & cron -> Load `skills/nocobase-workflow-manage/SKILL.md`
- Webhook gateway & security -> Load `skills/basancorp-workflow-webhook/SKILL.md`
- External databases -> Load `skills/basancorp-data-source-external/SKILL.md`
- Document/invoice printing & PDF -> Load `skills/basancorp-tenant-print/SKILL.md`
- Multi-tenant / multi-space -> Load `skills/basancorp-multi-space/SKILL.md`
- Plugin development -> Load `skills/nocobase-plugin-development/SKILL.md` (Dual-client on v2.2, Rsbuild on v2.4, Headless Hooks on v3, Zero-Trust ACL, Row-level Locking)

## Key Rules
- Zero-hardcoded hex colors in React components: use theme semantic tokens.
- Physical state machine: "Approved != Physical state changed immediately".
- Dual-client compatibility for plugins on v2.2.x; Rsbuild support on v2.4-alpha.
- Never use `this.app.use()` in client plugins.

