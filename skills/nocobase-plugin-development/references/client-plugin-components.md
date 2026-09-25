# Client Plugin Class, Router, Settings Pages, React Components

### 4.1 Plugin class (`src/client-v2/plugin.tsx`)

```tsx
import { Plugin, Application } from '@nocobase/client-v2';

export class PluginMyFeatureClient extends Plugin<any, Application> {
  async afterAdd() {}    // lightweight init
  async beforeLoad() {}  // inter-plugin deps: this.app.pm.get('other')
  async load() {}        // MAIN hook — registration lives here
}
export default PluginMyFeatureClient;
```
`index.tsx`: `export { default } from './plugin';`

**Shortcuts on `this`**: `flowEngine` (alias `engine`), `router` (RouterManager — registration only), `pluginSettingsManager`, `t(key)` (auto-namespace), `context` (≡ `useFlowContext()` in components), `context.api`, `context.dataSourceManager`, `context.logger`, `app.eventBus` (EventTarget), `app.apiClient`, `ai` (AIManager).

**Key warnings**:
- Use `Plugin<any, Application>` for correct `pluginSettingsManager` types.
- In `load()` do NOT read runtime router state (`this.app.router.router.state`, `location`, `pathname`) — React RouterProvider may not be mounted. Register with `this.router.add()` only; read route state in components/handlers.
- `this.router` (plugin) = RouterManager for registration; `ctx.router` (components) = React Router for navigation. Different objects.

### 4.2 Routes (auto `/v` prefix)

```tsx
async load() {
  this.router.add('my-page', {
    path: '/my-page',                                   // → /v/my-page
    componentLoader: () => import('./pages/MyPage'),    // lazy; page needs `export default`
  });
  // Nested (parent element + <Outlet/> from react-router-dom; dot notation = nesting)
  this.router.add('root', { element: <div><nav/><Outlet/></div> });
  this.router.add('root.user', { path: '/user/:id', componentLoader: () => import('./pages/UserPage') });
}
```
Default routes: `admin` `/v/admin/*`, `admin.page` `/v/admin/:name`, `admin.settings` `/v/admin/settings/*`.
In components: `ctx.router.navigate('/my-page')`; params via `ctx.route.params.id`; URL via `ctx.location.pathname/search/hash`.

### 4.3 Settings pages

```tsx
this.pluginSettingsManager.addMenuItem({
  key: 'my-feature', title: this.t('My Feature Settings'), icon: 'SettingOutlined',
});
this.pluginSettingsManager.addPageTabItem({
  menuKey: 'my-feature', key: 'index',                  // 'index' → /v/admin/settings/my-feature
  title: this.t('General'),
  componentLoader: () => import('./pages/GeneralPage'),
});
this.pluginSettingsManager.addPageTabItem({
  menuKey: 'my-feature', key: 'advanced',               // → /v/admin/settings/my-feature/advanced
  title: this.t('Advanced'),
  componentLoader: () => import('./pages/AdvancedPage'),
});
// 1 visible page → tabs auto-hidden; 2+ → tabs shown on top
```
Menu first, then pages. Icon = Ant Design v5 icon name string (`SettingOutlined`, `ApiOutlined`, `DatabaseOutlined`, `AppstoreOutlined`, `TableOutlined`...).

### 4.4 Components (plain React + Antd v5)

```tsx
// pages/MySettingsPage.tsx — settings with load/save via API
import React from 'react';
import { Form, Input, Button, Card, Space, message } from 'antd';
import { useFlowContext } from '@nocobase/flow-engine';
import { useRequest } from 'ahooks';
import { useT } from '../locale';

export default function MySettingsPage() {
  const ctx = useFlowContext();
  const t = useT();
  const [form] = Form.useForm();

  const { loading } = useRequest(
    () => ctx.api.request({ url: 'myPlugin:get', method: 'get' }),
    { onSuccess(res) { if (res?.data?.data) form.setFieldsValue(res.data.data); } },
  );
  const { run: save, loading: saving } = useRequest(
    (values) => ctx.api.request({ url: 'myPlugin:set', method: 'post', data: values }),
    { manual: true,
      onSuccess() { message.success(t('Saved successfully')); },
      onError() { message.error(t('Save failed')); } },
  );
  // ... render <Card><Form>...</Form></Card>
}
```

Reactive state (dialog forms, shared state): `observable` + `observer` from `@nocobase/flow-engine` instead of `useState`. Data fetching: `useRequest` from `ahooks`. Runtime UI = plain React + Antd (NOT uiSchema — uiSchema is only for FlowModel config panels). Pages must `export default`.
