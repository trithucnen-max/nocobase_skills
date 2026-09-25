# ResourceManager, ACL, Middleware, Request Context

### 3.3 ResourceManager — custom APIs

URL pattern: `/api/<resource>:<action>[/<filterByTk>]` — action in path, not HTTP verb.
```
GET  /api/posts:list        GET  /api/posts:get/1      POST /api/posts:create
POST /api/posts:update/1    POST /api/posts:destroy/1  POST /api/posts/1/tags:add
```

```ts
async load() {
  // Global action (all resources)
  this.app.resourceManager.registerActionHandlers({
    export: async (ctx, next) => {
      const repo = ctx.db.getRepository(ctx.action.resourceName);
      ctx.body = await repo.find({ filter: ctx.action.params.filter });
      await next();
    },
  });
  // Resource-scoped: POST /api/posts:publish
  this.app.resourceManager.registerActionHandlers({
    'posts:publish': async (ctx, next) => {
      const { filterByTk } = ctx.action.params;
      await ctx.db.getRepository('posts').update({
        filterByTk, values: { status: 'published', publishedAt: new Date() },
      });
      ctx.body = { success: true };
      await next();
    },
  });
  // Association-scoped: 'posts.comments:pin'
  // Non-collection custom resource:
  this.app.resourceManager.define({
    name: 'myService',
    actions: {
      check: async (ctx, next) => { ctx.body = { status: 'ok' }; await next(); },
    },
  });
  this.app.acl.allow('myService', 'check', 'public');   // don't forget ACL!
  // Resource-level middleware:
  this.app.resourceManager.use(async (ctx, next) => { await next(); });
}
```

In handlers: `ctx.action.{actionName,resourceName,params}`, params incl. `filter`, `filterByTk`, `values`, `fields`, `appends`, `except`, `sort`, `page`, `pageSize`, `paginate`, `tree`, `whitelist`, `blacklist`; `ctx.getCurrentRepository()`, `ctx.dataSource`.

**Other data sources**: `this.app.dataSourceManager.get('external').resourceManager.registerActionHandlers(...)` or `afterAddDataSource((ds) => {...})` for all.

### 3.6 ACL

```ts
async load() {
  this.app.acl.allow('*', '*', 'loggedIn');                       // common default
  this.app.acl.allow('myResource', 'check', 'public');            // no auth
  this.app.acl.allow('myResource', ['list', 'get'], 'loggedIn');
  this.app.acl.allow('orders', 'delete', (ctx) => ctx.auth.user?.role === 'admin');

  this.app.acl.registerSnippet({ name: 'ui.myFeature', actions: ['myResource:*'] });
  this.app.acl.setAvailableAction('export', {
    displayName: '{{t("Export")}}', type: 'existing-data', onNewRecord: false,
  });
  this.app.acl.use(async (ctx, next) => {                         // custom permission logic
    const { resourceName, actionName } = ctx.action;
    if (resourceName === 'publicForms' && actionName === 'submit') {
      if (ctx.request.body?.password === ctx.state.formPassword) ctx.permission = { skip: true };
      else ctx.throw(403, 'Invalid password');
    }
    await next();
  });
  this.app.acl.addFixedParams('roles', 'destroy', () => ({        // hard data constraint
    filter: { $and: [{ 'name.$ne': 'root' }, { 'name.$ne': 'admin' }, { 'name.$ne': 'member' }] },
  }));
  const r = this.app.acl.can({ roles: ['admin'], resource: 'posts', action: 'delete' });
}
```
Per-data-source ACL: `ds.acl.allow(...)` / `afterAddDataSource((ds) => ds.acl.allow(...))`.

### 3.7 Middleware (Koa onion model; register in `load()`)

Four levels, execution order for resource requests: `acl.use()` → `resourceManager.use()` → `dataSourceManager.use()` → `app.use()`. (Non-resource requests: only `app.use()`.)

```ts
this.app.use(mw, { tag: 'myTag' });
this.app.use(early, { before: 'myTag' });
this.app.resourceManager.use(between, { after: 'parseToken', before: 'checkRole' });
// Onion: code before await next() runs on the way in; after — on the way out
```

Common patterns: request logging, auth gate (`ctx.throw(403)`), response transform (mutate `ctx.body` after `await next()`).

### 3.8 Request Context (`ctx` — Koa Context extended)

| Property | Purpose |
|---|---|
| `ctx.action` | `{ actionName, resourceName, params }` |
| `ctx.db` | Database (`ctx.db.getRepository(...)`) |
| `ctx.auth.user` | current user (else `ctx.throw(401)`) |
| `ctx.state.currentRoles` | `string[]` |
| `ctx.t(key, { ns })` | i18n by `X-Locale` header or `?locale=` |
| `ctx.cache` | cache ops |
| `ctx.logger` | `info/warn/error/debug` |
| `ctx.app` | app instance (`ctx.app.pm.get('plugin')`) |
| `ctx.dataSource` | current data source |
| `ctx.permission = { skip: true }` | bypass ACL |
| `ctx.getCurrentRepository()` | repo of current resource |
