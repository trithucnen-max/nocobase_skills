# Build, Package, Distribute & Dependency Rules

## 6. Build, Package & Distribute

```bash
# CLI-managed (from <app-path>/source/)          # plain repo (repo root)
nb source build @my-project/plugin-hello          yarn build @my-project/plugin-hello
yarn nocobase tar @my-project/plugin-hello        yarn build @my-project/plugin-hello --tar
```
Client compiled with **Rsbuild**, server with **tsup** → `dist/`; tarball → `storage/tar/<name>-<version>.tgz`.
Deploy: extract into target app's `storage/plugins/`, or `nb plugin import <file.tgz|url|npm-spec>` (restart afterwards).

### 6.1 Clean Production Packaging (Zero macOS AppleDouble Files)

When distributing plugins as `.tgz` for uploading via NocoBase Plugin Manager (`/admin/settings/plugin-manager`), ensure:
1. `package.json` contains an explicit `"files"` array:
   ```json
   "files": ["dist", "client.js", "client.d.ts", "client-v2.js", "client-v2.d.ts", "server.js", "server.d.ts", "package.json", "README.md", "PRD.md"]
   ```
2. `.npmignore` contains:
   ```
   /node_modules
   /src
   /scripts
   *.tgz
   !/dist
   ```
3. Run packaging with `COPYFILE_DISABLE=1 npm pack` to eliminate `._*` corruption:
   ```bash
   cd packages/plugins/@itngon/plugin-<slug>
   yarn build
   COPYFILE_DISABLE=1 npm pack
   tar -tzf *.tgz | grep "^\._"  # verify 0 dot-underscore files
   ```

See `references/paid-modules-and-multitenant-standard.md` for full monetization and multi-tenant isolation specifications.

Optional `build.config.ts` in plugin root:
```ts
import { defineConfig } from '@nocobase/build';
export default defineConfig({
  modifyRsbuildConfig: (config) => config,   // https://rsbuild.rs/config/index
  modifyTsupConfig: (config) => config,      // https://tsup.egoist.dev
  beforeBuild: (log) => {}, afterBuild: (log) => {},
});
```

## 7. Dependency Rules

NocoBase core packages (`@nocobase/server`, `client-v2`, `database`, `flow-engine`, `acl`, `auth`, `cache`, `resourcer`, `sdk`, `utils`...) and shared libs (`react`, `react-dom`, `antd`, `@ant-design/icons`, `@formily/*`, `dayjs`, `lodash`, `axios`, `ahooks`, `koa`, `sequelize`, `i18next`, `@dnd-kit/*`) are **provided by the host app — do NOT bundle**; treat as externals/peer deps. Inter-plugin dependencies go in `package.json` so `pm` resolves load order.

---
