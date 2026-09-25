# FlowEngine: FlowModel, registerFlow, FlowRuntimeContext, Resource API

### 4.5 FlowEngine: FlowModel + registerFlow

**Concepts**: FlowModel = configurable component (rendering + props + persisted config). Flow = config flow (settings panel `uiSchema` + business logic `handler`). Model tree via `setSubModel`/`addSubModel`; reuse via `createFork`; persist via `model.save()`.

**Base-class decision chain**:
```
BlockModel               — static UI, no data source
 └ DataBlockModel        — custom data fetching; grouped under "Data blocks" menu
    └ CollectionBlockModel — bound to collection, auto fetch; custom rendering
       └ TableBlockModel   — full table (columns, action bar, pagination, sorting) — most common
```
Other built-ins to extend: `FormBlockModel`, `DetailsBlockModel`, `FilterFormBlockModel`; sub-models `TableColumnModel`, `FormItemModel`, `DetailsItemModel`, `FormGridModel`...

**BlockModel template** (3 steps: renderComponent → define → registerFlow):

```tsx
// models/SimpleBlockModel.tsx
import React from 'react';
import { BlockModel } from '@nocobase/client-v2';
import { tExpr } from '../locale';                       // from locale.ts, NOT flow-engine

export class SimpleBlockModel extends BlockModel {
  renderComponent() {
    return <div dangerouslySetInnerHTML={{ __html: this.props.html }} />;
  }
}
SimpleBlockModel.define({ label: tExpr('Simple block') });
SimpleBlockModel.registerFlow({
  key: 'simpleBlockSettings',
  title: tExpr('Simple block settings'),
  on: 'beforeRender',
  steps: {
    editHtml: {
      title: tExpr('Edit HTML Content'),
      uiSchema: {
        html: { type: 'string', title: tExpr('HTML Content'),
                'x-decorator': 'FormItem', 'x-component': 'Input.TextArea' },
      },
      defaultParams: { html: '<h3>Hello</h3>' },
      handler(ctx, params) { ctx.model.props.html = params.html; },
    },
  },
});
```

**CollectionBlockModel templates**:

```tsx
// Multi-record (BlockSceneEnum.many)
import { BlockSceneEnum, CollectionBlockModel } from '@nocobase/client-v2';
import { MultiRecordResource } from '@nocobase/flow-engine';

export class ManyRecordBlockModel extends CollectionBlockModel {
  static scene = BlockSceneEnum.many;                    // many | one | new | select | filter | oam | subForm | bulkEditForm
  createResource() { return this.context.makeResource(MultiRecordResource); }
  get resource() { return this.context.resource as MultiRecordResource; }
  renderComponent() {
    const data = this.resource.getData();
    return <ul>{data.map((i: any) => <li key={i.id}>{i.title}</li>)}</ul>;
  }
}
ManyRecordBlockModel.define({ label: tExpr('Card list') });

// Single-record: scene = BlockSceneEnum.one; createResource() → SingleRecordResource

// Table restricted to one collection
export class TodoBlockModel extends TableBlockModel {
  static filterCollection(collection: Collection) { return collection.name === 'todoItems'; }
}
TodoBlockModel.define({ label: tExpr('Todo block') });
```

**`define()` params**: `label` (tExpr!), `icon`, `sort` (lower = higher), `hide: boolean | (ctx)=>boolean`, `group`.

**registerFlow reference**:

```ts
MyModel.registerFlow({
  key: 'mySettings',                    // unique within model class
  title: tExpr('My settings'),
  on: 'beforeRender',                   // see events below
  steps: {
    step1: {
      title: tExpr('Step 1'),
      sort: 0, hideInSettings: false, preset: false, paramsRequired: false,
      uiSchema: { /* config panel */ },
      defaultParams: { k: 'v' },        // or (ctx) => ({ userId: ctx.model.uid })
      handler(ctx, params) { /* logic */ },
    },
  },
  defaultParams: { step1: { title: 'x' } },   // flow-level defaults at creation (fills missing)
});
```

**Events (`on`)**: `'beforeRender'`, `'click'`, `'submit'`, `'reset'`, `'remove'`, `'openView'`, `'search'`, `'dropdownOpen'`, `'popupScroll'`, `'customRequest'`, `'collapseToggle'`, or any custom string via `dispatchEvent('myEvent')`.

**Phase mechanism** (ordering vs built-in flows):
```ts
on: 'click'                                            // = beforeAllFlows (default)
on: { eventName: 'click', phase: 'afterAllFlows' }
on: { eventName: 'click', phase: 'beforeFlow',  flowKey: 'buttonSettings' }
on: { eventName: 'click', phase: 'afterStep',   flowKey: 'buttonSettings', stepKey: 'general' }
// phases: beforeAllFlows | afterAllFlows | beforeFlow | afterFlow | beforeStep | afterStep
```

**uiSchema components** (JSON Schema, each field `'x-decorator': 'FormItem'`): `Input`, `Input.TextArea`, `InputNumber`, `Switch` (type boolean), `Select` (+`enum: [{label,value}]`), `DatePicker`; `required: true` supported.

### 4.6 FlowRuntimeContext (`ctx`) — in handlers & components

| Property | Purpose |
|---|---|
| `ctx.model` / `ctx.blockModel` | current model / parent block model |
| `ctx.api` | `ctx.api.request({ url, method, data, params })` (axios-like); `ctx.request(config)` shortcut |
| `ctx.makeResource(Class)` | create Multi/SingleRecordResource |
| `ctx.viewer` | `ctx.viewer.dialog({ title, content: (view) => <Form onCancel={() => view.close()} ... /> })`, `.drawer(...)` |
| `ctx.message` / `ctx.notification` | antd feedback |
| `ctx.t(key, { ns })` | ⚠️ manual `{ ns: 'pkg-name' }` needed (no auto-namespace) — prefer `useT()` in components |
| `ctx.router.navigate()` / `ctx.route` / `ctx.location` | navigation & route state |
| `ctx.token`, `ctx.role`, `ctx.auth` | auth |
| `ctx.themeToken` | antd theme tokens |
| `ctx.exit()` / `ctx.exitAll()` | stop remaining steps / all flows |
| `ctx.getStepParams(flowKey, stepKey)` / `ctx.setStepParams(...)` | cross-step params |
| `ctx.model.context.record` / `.recordIndex` | row data/index in record-level contexts |

### 4.7 Resource API (`@nocobase/flow-engine`)

**MultiRecordResource** (lists/tables):
```ts
resource.getData(); resource.hasData(); await resource.get(1);
await resource.create(data, { refresh: false });
await resource.update(1, { title: 'x' });
await resource.destroy([1, 2]); await resource.destroySelectedRows();
await resource.refresh();
resource.getPage(); resource.setPage(2); resource.getPageSize(); resource.setPageSize(50);
resource.getCount(); resource.getTotalPage();
await resource.next(); await resource.previous(); await resource.goto(3);
resource.setSelectedRows(rows); resource.getSelectedRows();
```

**SingleRecordResource** (forms/details):
```ts
resource.getData();                       // object | null
resource.isNewRecord = true;              // save() → create
resource.setFilterByTk(1);                // sets isNewRecord=false; save() → update
await resource.save(values); await resource.destroy(); await resource.refresh();
```

**Common**: `setFilter({...})`, `addFilterGroup('status', {...})` / `removeFilterGroup('status')` (auto `$and` aggregation), `setFields([...])`, `setAppends(['author'])`, `addAppends([...])`, `setSort(['-createdAt'])`, `setFilterByTk(1)`, `setResourceName('users.tags')`, `setSourceId(1)`, `setDataSourceKey('secondary')`, `loading`, `getMeta('totalCount')`, `getError()/clearError()`, `on('refresh'|'saved', cb)`.
