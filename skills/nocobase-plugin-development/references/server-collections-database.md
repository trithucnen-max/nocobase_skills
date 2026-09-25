# Collections & Database / Repository API

### 3.2 Collections (`src/server/collections/*.ts` — auto-loaded before all plugins' `load()`)

```ts
import { defineCollection, extendCollection } from '@nocobase/database';

export default defineCollection({
  name: 'todos',
  title: 'Todo Items',
  fields: [
    { type: 'string', name: 'title' },
    { type: 'boolean', name: 'completed', defaultValue: false },
    { type: 'integer', name: 'priority', defaultValue: 0 },
    { type: 'belongsTo', name: 'assignee', target: 'users', foreignKey: 'assigneeId' },
    { type: 'hasMany', name: 'comments', target: 'comments', foreignKey: 'todoId' },
    { type: 'belongsToMany', name: 'tags', target: 'tags', through: 'todosTags' },
  ],
});

export default extendCollection({           // add fields to existing table
  name: 'users',
  fields: [ { type: 'string', name: 'department' } ],
});
```

**CollectionOptions**: `name` (required), `title`, `fields`, `autoGenId` (bigInt PK, default true), `timestamps` (createdAt/updatedAt, default true), `paranoid` (soft delete deletedAt, default false), `filterTargetKey` (**set `'id'` for UI block-picker visibility**), `inherits` (PostgreSQL), `model`, `repository`.

**Field types** (common params on all column fields: `name`*, `defaultValue`, `allowNull` (default true), `unique`, `primaryKey`, `autoIncrement`, `index`, `comment`, `hidden`):

| Category | Types & key params |
|---|---|
| Text | `string` (VARCHAR(255); `length`, `trim`), `text` (`length: 'tiny'\|'medium'\|'long'` MySQL) |
| Number | `integer`, `bigInt`, `float`, `double`, `real`, `decimal` (`precision`, `scale`) |
| Boolean | `boolean`, `radio` |
| Date/Time | `date` (DATE(3), most common; `defaultToCurrentTime`, `onUpdateToCurrentTime`), `dateOnly`, `time` (`timezone`), `datetimeTz`, `datetimeNoTz`, `unixTimestamp` (`accuracy: 'second'\|'millisecond'`) |
| Structured | `json` (`jsonb?` PG), `jsonb`, `array` (`dataType`, `elementType`), `set` |
| IDs | `uid` (`prefix`), `uuid` (`autoFill`), `nanoid` (`size` 12, `customAlphabet`), `snowflakeId` |
| Special | `password` (auto salted-hash), `encryption`, `virtual` (no column), `context` (auto from request ctx, `dataIndex: 'user.id'`, `createOnly`) |
| Relations (no column) | `belongsTo` (`target`, `foreignKey`, `targetKey?`, `onDelete?`), `hasOne`, `hasMany` (`sortBy?`), `belongsToMany` (`through`, `otherKey?`) |

Defining a collection **auto-generates REST resources** (`list/get/create/update/destroy/firstOrCreate/updateOrCreate` + association `add/remove/set/toggle`). After changing collections on an installed plugin → run upgrade (`nb app upgrade` / `yarn nocobase upgrade`).

### 3.4 Database & Repository API

```ts
const repo = this.db.getRepository('posts');       // or ctx.db in handlers

await repo.find({ filter, fields, except, appends, sort: ['-createdAt'], limit, offset });
await repo.findOne({ filterByTk: 1, appends: ['profile'] });
await repo.count({ filter });
const [rows, total] = await repo.findAndCount({ filter, limit: 20, offset: 0 });
await repo.create({ values: { title: 'x', tags: [{ id: 1 }, { name: 'new' }] } });
await repo.createMany({ records: [...] });
await repo.update({ filterByTk: 1, values, whitelist: ['status'] });
await repo.destroy({ filterByTk: [1, 2, 3] });

const Model = this.db.getModel('users');           // raw Sequelize: Model.findByPk(1)
```

**Filter operators**: `$eq $ne $gt $gte $lt $lte`, `$like $notLike $includes`, `$null $notNull`, `$in $notIn`, `$isTruly $isFalsy`, `$and $or`, relation filtering `'posts.comments.content': { $like: '%bug%' }`.
> ⚠️ These are server-side operators. For filters persisted for standard frontend display/editing, use the frontend operator group of the terminal field (e.g. `$dateBefore`/`$dateAfter` for dates) — see nocobase-utils filter reference. Don't copy server operators into UI config just because they work.

**Registration APIs (in `beforeLoad()`)**: `db.registerFieldTypes()`, `db.registerModels()`, `db.registerRepositories()`, `db.registerOperators()`.
