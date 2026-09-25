---
name: basancorp-multi-space
description: >-
  Vận hành và quản trị plugin Đa Không Gian Làm Việc / Multi-Tenant của BasanCorp (@itngon/plugin-multi-space) trên NocoBase v2.
  Dùng khi triển khai mô hình B2B SaaS, tập đoàn đa công ty thành viên, cách ly dữ liệu Schema-per-Tenant,
  cấu hình gói plugin cho từng Tenant (Core Mandatory vs Add-on), chế độ Ghost Login đăng nhập quản trị khẩn cấp,
  và giao diện tinh gọn cho khách hàng cuối (Tenant Clean View).
version: 1.1.0
license: MIT
metadata:
  hermes:
    tags: [nocobase, multi-tenant, multi-space, subapp, schema-per-tenant, ghost-login, basancorp]
    category: saas-architecture
    schema_version: "1.0"
    entrypoint: SKILL.md
  tags: [nocobase, basancorp, multi-space, multi-tenant, subapp, schema-per-tenant, ghost-login, saas]
---

# Kỹ Năng Quản Trị Đa Không Gian Làm Việc (`@itngon/plugin-multi-space`)

Plugin `@itngon/plugin-multi-space` là giải pháp quản trị Multi-Tenant chuyên sâu cho NocoBase v2, vận hành theo mô hình kiến trúc **Schema-per-Tenant** (`USE_DB_SCHEMA_IN_SUBAPP=true`). Mỗi không gian làm việc (Tenant / Công ty thành viên) sở hữu một schema CSDL độc lập, bảo mật tuyệt đối về dữ liệu kinh doanh.

---

## 1. Bản Đồ Phân Hệ & Kiến Trúc Vận Hành

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       MAIN APP (ỨNG DỤNG TỔNG)                          │
│                                                                         │
│  Giao diện Quản trị: /v/admin/settings/multi-space/applications         │
│  Cơ chế điều phối:   Plugin Registry, SubApp Lifecycle Manager          │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ Khởi tạo & Đồng bộ Schema
        ┌────────────────────────────┼────────────────────────────┐
        ▼                            ▼                            ▼
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│  TENANT 1 (A)    │         │  TENANT 2 (B)    │         │  TENANT 3 (C)    │
│  Schema: t_congtyA│         │  Schema: t_congtyB│         │  Schema: t_congtyC│
│  Gói: Pro        │         │  Gói: Enterprise │         │  Gói: Starter    │
│  Clean View      │         │  Clean View      │         │  Clean View      │
└──────────────────┘         └──────────────────┘         └──────────────────┘
```

---

## 2. Các Đặc Quyền & Tính Năng Trọng Yếu

### 1. Phân Loại Plugin 2 Tầng (Hybrid Plugin Governance)
- **Tầng 1 - Cốt lõi Bắt buộc (Core Mandatory)**: Toàn bộ plugin nền tảng không bao giờ được phép tắt trên Tenant (`auth`, `acl`, `users`, `departments`, `client-v2`...).
- **Tầng 2 - Tính năng Mở rộng (Add-ons)**: Bật/tắt linh hoạt theo gói thuê bao của từng Tenant (ví dụ: gói Starter không có Approval Flow, gói Enterprise có thêm Tenant Print và Webhook Gateway).

### 2. Giao Diện Tinh Gọn Khách Hàng Cuối (Tenant Clean View)
- Tự động ẩn hoàn toàn menu kỹ thuật khỏi giao diện Tenant: `Plugin manager`, `Workflow engine`, `API Keys`, `Audit Logs`.
- Khách hàng chỉ nhìn thấy đúng phân hệ nghiệp vụ họ được cấp quyền sử dụng, tránh gây hoang mang và triệt tiêu nguy cơ chỉnh sửa sai hệ thống.

### 3. Đăng Nhập Đặc Quyền Quản Trị Viên (Ghost Login)
- Cho phép Super Admin truy cập thẳng vào bất kỳ Tenant nào chỉ với 1 click từ Main App để bảo trì, sửa lỗi mà không cần hỏi mật khẩu khách hàng.
- Khi Super Admin truy cập bằng Ghost Login, hệ thống sẽ mở khóa lại các công cụ kỹ thuật để phục vụ việc chẩn đoán lỗi.

---

## 3. Danh Mục Developer & Management APIs

Các hành động quản trị được đăng ký trên resource `applications`:

```http
### 1. Tạo Không gian làm việc / Tenant mới
POST /api/applications:create
Authorization: Bearer <SUPER_ADMIN_TOKEN>
Content-Type: application/json

{
  "name": "congty_thanhvien_a",
  "displayName": "Công ty TNHH Thành Viên A",
  "adminEmail": "admin@congtya.vn",
  "adminPassword": "TemporaryPassword123@",
  "plan": "enterprise",
  "plugins": [
    "@itngon/plugin-approval-flow",
    "@itngon/plugin-tenant-print",
    "@basancorp/plugin-workflow-webhook"
  ]
}

### 2. Đăng nhập Quản trị viên (Ghost Login)
POST /api/applications:ghostLogin
Authorization: Bearer <SUPER_ADMIN_TOKEN>
Content-Type: application/json

{
  "appName": "congty_thanhvien_a"
}
// Trả về token đăng nhập đặc quyền trực tiếp vào subapp

### 3. Đồng bộ lại gói Plugin cho Tenant
POST /api/applications:syncPlugins
Authorization: Bearer <SUPER_ADMIN_TOKEN>
Content-Type: application/json

{
  "appName": "congty_thanhvien_a",
  "enabledPlugins": ["@itngon/plugin-approval-flow", "@itngon/plugin-tenant-print"]
}

### 4. Khởi động lại / Khôi phục SubApp Tenant (Restart SubApp)
POST /api/applications:restartSubApp
Authorization: Bearer <SUPER_ADMIN_TOKEN>
Content-Type: application/json

{
  "appName": "congty_thanhvien_a"
}

### 5. Thống kê tài nguyên & Dung lượng Tenant
GET /api/applications:getStats?appName=congty_thanhvien_a
Authorization: Bearer <SUPER_ADMIN_TOKEN>
```

---

## 4. Checklist Triển Khai Multi-Tenant An Toàn

- [ ] Thiết lập biến môi trường `USE_DB_SCHEMA_IN_SUBAPP=true` trong file `.env` của NocoBase.
- [ ] Tên Tenant (`name`) chỉ dùng chữ cái viết thường không dấu, số và dấu gạch dưới (`_`).
- [ ] Luôn kiểm tra danh mục plugin bắt buộc trước khi cấp phát subapp mới.
- [ ] Định kỳ chạy lệnh dọn dẹp các subapp đã hết hạn thuê bao để giải phóng dung lượng RAM máy chủ.
