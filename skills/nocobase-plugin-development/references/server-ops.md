# Cache, Migrations, Server i18n, DataSourceManager, Testing

### 3.9 Cache

```ts
await this.app.cache.set('key', 'value', { ttl: 3600 });   // seconds
const v = await this.app.cache.get('key');  await this.app.cache.del('key');

const myCache = await this.app.cacheManager.createCache({
  name: 'myPlugin', prefix: 'plugin:cache:', store: 'memory', max: 1000,
});
const data = await myCache.wrap('user:1', async () => fetchFromDb(1), { ttl: 3600 });
// mset/mget/mdel; setValueInObject/getValueInObject; keys(); ttl(); reset()
```
Backends: `memory` (lru-cache), `redis` (cache-manager-redis-yet). Custom stores: `app.cacheManager.registerStore({ name, store, ... })`. Key convention: `module:resource:id`.

### 3.12 Migrations (`src/server/migrations/*.ts`)

```bash
nb scaffold migration add-nickname-field --pkg @my-project/plugin-users --on afterSync
# plain repo: yarn nocobase create-migration ... --on=afterLoad
```

```ts
import { Migration } from '@nocobase/server';

export default class extends Migration {
  on = 'afterLoad';              // beforeLoad (DDL early) | afterSync (DDL after sync) | afterLoad (Repository data ops)
  appVersion = '<1.5.0';         // run only when upgrading from below this version
  async up() {
    // Available: this.db, this.sequelize, this.queryInterface, this.app, this.plugin
    await this.queryInterface.addColumn('users', 'nickname',
      { type: this.sequelize.Sequelize.STRING, allowNull: true });
    await this.sequelize.transaction(async (t) => {
      await this.sequelize.query(`UPDATE users SET nickname = username WHERE nickname IS NULL`, { transaction: t });
    });
  }
}
```
Triggered by `nb app upgrade` / `yarn nocobase upgrade`. One migration per change; test with `createMockServer({ plugins: ['my-plugin'], version: '1.2.0' })` + `app.runCommand('upgrade')`.

### 3.13 i18n (server)

- Files: `src/locale/en-US.json`, `zh-CN.json`; `{{var}}` interpolation; new files need app restart. Verify: `/api/app:getLang?locale=zh-CN`.
- `this.t('Hello')` ≡ `ctx.t('Hello', { ns: pluginPkgName })`.
- `ctx.t()` follows `X-Locale` header > `?locale=` query.
- Global (CLI): `this.app.i18n.changeLanguage('zh-CN'); this.app.i18n.t('...')`.

### 3.14 DataSourceManager

Each `DataSource` has its own `collectionManager`, `resourceManager`, `acl`. Main shortcuts: `app.db` = main's `collectionManager.db`; `app.acl` = main's `acl`; `app.resourceManager` = main's.

```ts
this.app.dataSourceManager.use(async (ctx, next) => { await next(); });           // all DS middleware
this.app.dataSourceManager.beforeAddDataSource((ds) => { /* registerFieldTypes... */ });
this.app.dataSourceManager.afterAddDataSource((ds) => {                            // runtime registration for ALL DS
  ds.resourceManager.registerActionHandlers({ export: handler });
  ds.acl.allow('*', 'export', 'loggedIn');
});
```

### 3.15 Testing (`src/server/__tests__/*.test.ts`, vitest)

```ts
// DB-level
import { createMockDatabase, Database } from '@nocobase/database';
const db = await createMockDatabase();
await db.clean({ drop: true });
db.collection({ name: 'todos', fields: [{ type: 'string', name: 'title' }] });
await db.sync();
await db.getRepository('todos').create({ values: { title: 'x' } });
await db.close();

// API-level
import { createMockServer, MockServer } from '@nocobase/test';
const app: MockServer = await createMockServer({ plugins: ['users', 'auth', 'my-plugin'] });
const res = await app.agent().post('/todos:create').send({ title: 'Test' });
const agent = await app.agent().login(userOrId);                    // shorthand auth
// or manual: POST /auth:signIn → Bearer token
await app.destroy();

// Migration test: createMockServer({ plugins: [...], version: '1.2.0' }) → app.runCommand('upgrade')
```
Run: `yarn test packages/plugins/@my-project/plugin-hello/src/server`.

---
