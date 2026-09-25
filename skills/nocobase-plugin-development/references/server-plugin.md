# Server Plugin Lifecycle, Events, Cron, Commands

### 3.1 Plugin class & lifecycle (`src/server/plugin.ts`)

```ts
import { Plugin } from '@nocobase/server';

export class PluginMyFeatureServer extends Plugin {
  static async staticImport() {}        // before anything; register static commands
  async afterAdd() {}                   // instance created; basic setup only
  async beforeLoad() {}                 // registerFieldTypes/registerModels/registerRepositories/
                                        // registerOperators + db.on() listeners. NO DB ops.
  async load() {}                       // resources, actions, ACL, middleware. NO DB ops (not synced).
  async install() {}                    // ONCE on first enable: seed data, initial DB writes
  async afterEnable() {}                // every enable: timers, connections
  async afterDisable() {}               // cleanup, stop timers
  async remove() {}                     // uninstall: drop tables, delete files
  async handleSyncMessage(message: Record<string, any>) {}  // multi-node sync
}
export default PluginMyFeatureServer;
```

**Execution order**: app start `afterAdd → beforeLoad → load`; first enable adds `install()`; subsequent enables skip `install()`; disable → `afterDisable()`; delete → `remove()`.

**DB operation availability**: NO in `staticImport/afterAdd/beforeLoad/load` — YES in `install()`, `beforeEnable`+ , request handlers, `afterSync` event, `afterStart`, `afterInstall`, `afterUpgrade`, `afterEnablePlugin`...

**`this.app` members**: `db` (shorthand `this.db`), `resourceManager`, `acl`, `i18n`, `cacheManager` (+`app.cache`), `cronJobManager`, `cli`, `dataSourceManager`, `pm`, `logger`.

### 3.5 Events (register listeners in `beforeLoad()`)

`app.on()` app events: `beforeLoad/afterLoad`, `beforeStart/afterStart`, `beforeInstall/afterInstall`, `beforeStop/afterStop`, `beforeDestroy/afterDestroy`, `beforeLoadPlugin/afterLoadPlugin`, `beforeEnablePlugin/afterEnablePlugin`, `beforeDisablePlugin/afterDisablePlugin`, `afterUpgrade`.

`db.on()` DB events: `beforeSync/afterSync`, `beforeValidate/afterValidate`, `beforeCreate/afterCreate`, `beforeUpdate/afterUpdate`, `beforeSave/afterSave`, `beforeDestroy/afterDestroy`, `afterCreateWithAssociations`, `afterUpdateWithAssociations`, `afterSaveWithAssociations`, `beforeDefineCollection/afterDefineCollection`.

```ts
this.db.on('users.afterCreate', async (model, options) => { /* audit, sync... */ });
this.app.on('afterStart', async () => this.app.logger.info('started'));
```

### 3.10 Cron jobs

```ts
this.app.cronJobManager.addJob({
  cronTime: '0 0 * * *', onTick: async () => { /* ... */ },
  timeZone: 'Asia/Shanghai', start: true,
});
```

### 3.11 Custom CLI commands

```ts
// src/server/commands/*.ts — dynamic (requires plugin enabled)
export default function (app: Application) {
  app.command('echo').option('-v, --version')
     .auth()      // verify DB config
     .preload()   // run app.load() first
     // .ipc()    // talk to RUNNING instance
     .action(async (options) => { /* ... */ });
}
// Static (works without enabling) — in staticImport():
static staticImport() {
  Application.registerStaticCommand((app) => {
    app.command('setup').action(async () => { /* ... */ });
  });
}
```
