# Quy Chuẩn Thiết Kế Module Trả Phí (@itngon/*) & Multi-Tenant Resilience

Tài liệu này định nghĩa tiêu chuẩn kiến trúc bắt buộc áp dụng cho toàn bộ các plugin thương mại mở rộng do `@itngon` phát triển trên nền tảng NocoBase v2.

---

## 1. Nguyên Tắc Cốt Lõi (Core Tenets)

1. **Phân biệt rạch ròi Module Trả Phí vs Tiện ích Nền tảng**:
   - **Cốt lõi miễn phí (Free / Core)**: Các plugin mặc định của NocoBase (`@nocobase/plugin-users`, `@nocobase/plugin-workflow`, `@nocobase/plugin-file-manager`, v.v.). Hệ thống tự động kích hoạt cho mọi tenant hoặc miễn phí sử dụng.
   - **Module trả phí (@itngon Enterprise Add-ons)**: Các plugin độc quyền do team phát triển (`@itngon/plugin-approval-flow`, `@itngon/plugin-email-manager`, `@itngon/plugin-tenant-print`, `@itngon/plugin-auth-google`, v.v.). Chỉ những module này mới được đưa vào bảng tính phí gói dịch vụ (SaaS Plans).

2. **Khả năng tự phục hồi bộ nhớ (RAM Resilience & Auto-Evict)**:
   - Trong kiến trúc Multi-Tenant (`PostgreSQL Schema-per-Tenant`), khi tạo không gian mới mà gặp lỗi (ví dụ: thiếu dependency, timeout DB), tiến trình Node.js không được phép giữ lại instance rác trong RAM của Supervisor.
   - Luôn phải kích hoạt cơ chế dọn dẹp RAM trước khi tạo (`beforeCreate`), giải phóng khi lỗi (`afterCreate catch`), và có API thủ công (`flushCache`) cho Admin.

3. **Nguyên tắc "Chỉ cấp phát những gì đã có" (Installed-Only Enforcement)**:
   - Admin tổng chỉ được phép cấp phát các plugin thực sự ĐÃ CÀI ĐẶT và ĐANG CHẠY (`isInstalled: true`) trên hệ thống.
   - Các plugin chưa cài đặt (chưa upload file `.tgz`) phải hiển thị ở trạng thái mờ (`opacity: 0.6`), gắn nhãn "Chưa cài đặt trên Admin", và **vô hiệu hóa checkbox (`disabled: true`)** trên toàn bộ giao diện (Tạo mới, Cấu hình, Kế thừa tự động). Không bao giờ được gửi tên plugin chưa cài vào mảng `options.plugins` của tenant.

---

## 2. Tiêu Chuẩn `package.json` cho Plugin `@itngon/*`

Mọi plugin mang thương hiệu `@itngon` bắt buộc phải có cấu trúc `package.json` chuẩn hóa như sau:

```json
{
  "name": "@itngon/plugin-<slug>",
  "displayName": "Tên Hiển Thị Tiếng Việt (Tên Tiếng Anh)",
  "description": "Mô tả tính năng ngắn gọn, chuyên nghiệp theo phong cách doanh nghiệp B2B",
  "version": "1.0.0",
  "license": "MIT",
  "main": "dist/server/index.js",
  "itngon": {
    "isPaid": true,
    "commercialTier": "paid",
    "category": "operations | communication | print | auth | management",
    "requiredOnAdmin": true
  },
  "files": [
    "dist",
    "client.js",
    "client.d.ts",
    "client-v2.js",
    "client-v2.d.ts",
    "server.js",
    "server.d.ts",
    "package.json",
    "README.md",
    "PRD.md"
  ],
  "scripts": {
    "build": "nocobase build",
    "pack": "COPYFILE_DISABLE=1 npm pack"
  },
  "peerDependencies": {
    "@nocobase/client": "2.x",
    "@nocobase/client-v2": "2.x",
    "@nocobase/database": "2.x",
    "@nocobase/flow-engine": "2.x",
    "@nocobase/server": "2.x",
    "@nocobase/utils": "2.x"
  }
}
```

### Yêu Cầu Trường Dữ Liệu:
- `"itngon.isPaid": true`: Đánh dấu là module thương mại để Multi-Space Control Plane nhận diện và gắn huy hiệu `💎 Module Trả Phí`.
- `"files"` array: Bắt buộc khai báo rõ `"dist"` và các file root entry để lệnh `npm pack` không bị ảnh hưởng bởi file `.gitignore` gốc của NocoBase.

---

## 3. Tiêu Chuẩn `.npmignore`

Bắt buộc tạo file `.npmignore` trong thư mục gốc của plugin để đảm bảo các file mã nguồn và file rác không bị đóng gói, nhưng bắt buộc **giữ lại thư mục `dist/`**:

```gitignore
/node_modules
/src
/scripts
*.tgz
.DS_Store
!/dist
```

---

## 4. Cơ Chế Safe Multi-Tenant Trong Backend Multi-Space

### 4.1. Auto-Evict Trong Process Adapter (`legacy-adapter.ts`)
Khi thêm một tenant vào Supervisor, không bao giờ được phép quăng lỗi `app ... already exists` nếu instance cũ trong RAM là rác (không tồn tại trong DB):

```typescript
// Trong legacy-adapter.ts:
async addApp(app: Application) {
  if (this.apps[app.name]) {
    const dbApp = await app.db.getRepository('applications').findOne({
      filter: { name: app.name }
    }).catch(() => null);

    if (!dbApp) {
      // Instance cũ trong RAM không có trong DB => Evict ngay lập tức
      await this.removeApp(app.name).catch(() => {});
    } else {
      throw new Error(`app ${app.name} already exists`);
    }
  }
  this.apps[app.name] = app;
}
```

### 4.2. Safe Create Lifecycle Hook (`server.ts`)
Trước khi bắt đầu tạo schema, luôn gọi xóa cache RAM dự phòng:

```typescript
this.app.db.on('applications.beforeCreate', async (model) => {
  const appName = model.get('name');
  if (appName) {
    await supervisor.removeApp(appName).catch(() => {});
  }
});
```

### 4.3. Quét Dynamic Plugin Khả Dụng (`applications:getAvailablePlugins`)
Backend tổng hợp danh sách plugin từ cả 4 nguồn:
1. `this.app.pm.pluginInstances` (RAM)
2. `this.app.pm.pluginAliases` (RAM aliases)
3. Bảng `applicationPlugins` (`enabled: true`)
4. SQL fallback trực tiếp trên PostgreSQL

Kết quả trả về cho client định danh rõ:
```json
{
  "id": "@itngon/plugin-approval-flow",
  "name": "Quy trình Phê duyệt Nhiều Cấp",
  "isPaid": true,
  "isInstalled": true
}
```

---

## 5. Quy Trình Đóng Gói Và Xuất Bản Sạch (Packaging Runbook)

### BƯỚC 1: Biên dịch toàn diện (Dual-Client + Server)
```bash
yarn build @itngon/plugin-<slug>
```
Đảm bảo kết quả hiển thị:
- `build plugin client` -> `dist/client/`
- `build plugin client-v2` -> `dist/client-v2/`
- `build plugin server` -> `dist/server/`

### BƯỚC 2: Đóng gói sạch (Zero AppleDouble)
> ⚠️ **CẢNH BÁO:** Trên macOS, lệnh `tar` mặc định hoặc `npm pack` không có cờ môi trường có thể tạo ra các file mở rộng ẩn dạng `._*`. Khi upload lên máy chủ Linux, Node.js sẽ cố nạp các file này và quăng lỗi `SyntaxError: Invalid or unexpected token`.

Chạy lệnh đóng gói bắt buộc:
```bash
# Trong thư mục của plugin:
COPYFILE_DISABLE=1 npm pack
```

### BƯỚC 3: Kiểm tra tính toàn vẹn (Verification)
Kiểm tra file `.tgz` vừa tạo bằng 2 lệnh kiểm tra:

1. **Kiểm tra không có file rác macOS**:
   ```bash
   tar -tzf itngon-plugin-<slug>-1.0.0.tgz | grep "^\._"
   ```
   *(Kết quả trả về rỗng = Đạt yêu cầu 100%)*

2. **Kiểm tra đã có thư mục dist đầy đủ**:
   ```bash
   tar -tzf itngon-plugin-<slug>-1.0.0.tgz | grep "dist/client-v2"
   ```
   *(Kết quả hiển thị file index.js của client-v2 = Đạt yêu cầu 100%)*

---

## 6. Tiêu Chuẩn 3-Tier Documentation Cho Mỗi Plugin

Mỗi plugin `@itngon/*` khi release phải có đủ 3 lớp tài liệu:
1. **`README.md`**: Dành cho Quản trị viên và Kỹ sư DevOps:
   - Tổng quan, giá trị thương mại, phân loại Gói Trả Phí.
   - Hướng dẫn cài đặt qua giao diện Plugin Manager và cấp phát cho Tenant.
   - Hướng dẫn cấu hình biến môi trường, quyền hạn ACL, và các bước khôi phục sự cố.
2. **`PRD.md`**: Dành cho Quản lý Sản phẩm và Đối tác:
   - Phân tích bài toán nghiệp vụ, chân dung người dùng (User Personas).
   - Đặc tả tính năng chi tiết, ma trận phân quyền, luồng dữ liệu E2E.
   - Tiêu chuẩn thương mại hóa (Gói Tiêu chuẩn, Vận hành, Nâng cao).
3. **`openwiki/`**: Dành cho Kỹ sư Lập trình:
   - Sơ đồ kiến trúc tầng Server, Model, API Resourcer.
   - Sơ đồ tương tác Client-V2 (FlowEngine, Settings, Router).
