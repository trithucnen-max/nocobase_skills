# Field/Action Models, Model Registration, Client Collections, Client i18n

### 4.8 Custom Field (FieldModel)

```tsx
import { ClickableFieldModel } from '@nocobase/client-v2';
import { DisplayItemModel } from '@nocobase/flow-engine';
import { Tag } from 'antd';
import { tExpr } from '../locale';

export class PriorityFieldModel extends ClickableFieldModel {
  public renderComponent(value: string) {
    // this.context.record / this.context.recordIndex available
    return value ? <Tag color={priorityColors[value]}>{value}</Tag> : <span>-</span>;
  }
}
PriorityFieldModel.define({ label: tExpr('Priority tag') });
DisplayItemModel.bindModelToInterface('PriorityFieldModel', ['input']);   // bind to interfaces
```
Interfaces: `input`, `textarea`, `integer`, `number`, `checkbox`, `select`, `multipleSelect`, `datetime`, `email`, `url`, `json`.
Built-in field models to extend: editable `InputFieldModel`, `SelectFieldModel`, `DateTimeFieldModel`, `RichTextFieldModel`, `AssociationFieldModel`...; display `DisplayTextFieldModel`, `DisplayNumberFieldModel`, `DisplayURLFieldModel`, `DisplayAssociationField`...

### 4.9 Custom Action (ActionModel)

```tsx
import { ActionModel, ActionSceneEnum } from '@nocobase/client-v2';
import { MultiRecordResource } from '@nocobase/flow-engine';
import { tExpr } from '../locale';

export class NewTodoActionModel extends ActionModel {
  static scene = ActionSceneEnum.collection;   // collection (toolbar) | record (row) | both | all
  defaultProps = { type: 'primary', children: tExpr('New todo') };   // antd ButtonProps
}
NewTodoActionModel.define({ label: tExpr('New todo') });
NewTodoActionModel.registerFlow({
  key: 'newTodoFlow', title: tExpr('New todo'), on: 'click',
  steps: {
    openForm: {
      async handler(ctx) {
        const resource = ctx.blockModel?.resource as MultiRecordResource;
        ctx.viewer.dialog({
          title: ctx.t('New todo'),
          content: (view) => (
            <NewTodoForm
              onSubmit={async (values) => {
                await resource.create(values);
                ctx.message.success(ctx.t('Created successfully'));
                view.close();
              }}
              onCancel={() => view.close()}
            />
          ),
        });
      },
    },
  },
});
```
Two action-form approaches: (a) `ctx.viewer.dialog()` + React form component; (b) `uiSchema` in the step (config-panel-based form, values arrive as `params`).
Record-level access: `ctx.model.context.record` / `.recordIndex`; collection-level: `ctx.blockModel?.resource`.
Built-in actions to extend: `AddNewActionModel`, `EditActionModel`, `ViewActionModel`, `DeleteActionModel`, `BulkDeleteActionModel`, `RefreshActionModel`, `FilterActionModel`, `LinkActionModel`, `UpdateRecordActionModel`.

### 4.10 Registration in `plugin.tsx` `load()`

```tsx
this.flowEngine.registerModelLoaders({            // lazy — ALWAYS this, not registerModels
  SimpleBlockModel:  { loader: () => import('./models/SimpleBlockModel') },
  TodoBlockModel:    { loader: () => import('./models/TodoBlockModel') },
  PriorityFieldModel:{ loader: () => import('./models/PriorityFieldModel') },
  NewTodoActionModel:{ loader: () => import('./models/NewTodoActionModel') },
});
```

### 4.11 Client collection registration (eventBus pattern — demo/bundled tables only)

```tsx
const myCollection = {
  name: 'myCollection', title: 'My Collection', filterTargetKey: 'id',
  fields: [
    { type: 'bigInt', name: 'id', primaryKey: true, autoIncrement: true, interface: 'id' },
    { type: 'string', name: 'title', interface: 'input',
      uiSchema: { type: 'string', title: 'Title', 'x-component': 'Input' } },
  ],
};
const addMyCollection = () => {
  const mainDS = this.flowEngine.dataSourceManager.getDataSource('main');
  if (mainDS && !mainDS.getCollection('myCollection')) mainDS.addCollection(myCollection);
};
this.app.eventBus.addEventListener('dataSource:loaded', (event: Event) => {
  if ((event as CustomEvent).detail?.dataSourceKey === 'main') addMyCollection();
});
```

### 4.12 i18n (client)

```ts
// src/client-v2/locale.ts — scaffold does NOT create this; create with EXACTLY:
import { tExpr as _tExpr, useFlowEngine } from '@nocobase/flow-engine';
// @ts-ignore
import pkg from './../../package.json';

export function useT() {
  const engine = useFlowEngine();
  return (str: string) => engine.context.t(str, { ns: [pkg.name, 'client'] });
}
export function tExpr(key: string) {
  return _tExpr(key, { ns: [pkg.name, 'client'] });
}
```

| Context | Function | Import |
|---|---|---|
| Plugin `load()` | `this.t('key')` | base class (auto ns) |
| React component | `const t = useT(); t('key')` | `../locale` |
| `define()` / `registerFlow()` / `defaultProps` | `tExpr('key')` (deferred `'{{t("key")}}'`) | `../locale` — NEVER `@nocobase/flow-engine` |
| Flow handler | `ctx.t('key', { ns: 'pkg-name' })` | ctx (manual ns) |

Locale JSON keys = English originals (auto-fallback); variables `{{name}}`; namespaces auto-scoped per plugin package.

---
