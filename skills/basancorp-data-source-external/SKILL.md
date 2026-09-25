---
name: basancorp-data-source-external
description: >-
  Vận hành và cấu hình plugin Kết nối CSDL Ngoại vi của BasanCorp (@basancorp/plugin-data-source-external) trên NocoBase v2.
  Dùng khi cần kết nối NocoBase với database bên ngoài (PostgreSQL, MySQL, MariaDB),
  ánh xạ các bảng ngoài thành collections, bật chế độ Chỉ Đọc (Enforced Read-Only Mode) bảo vệ CSDL nguồn,
  và đồng bộ cấu trúc bảng khi có thay đổi (1-Click Schema Drift Sync).
version: 1.1.0
license: MIT
metadata:
  hermes:
    tags: [nocobase, external-db, postgresql, mysql, read-only, schema-drift, basancorp]
    category: data-integration
    schema_version: "1.0"
    entrypoint: SKILL.md
  tags: [nocobase, basancorp, external-data-source, postgresql, mysql, read-only, schema-sync]
---

# Kỹ Năng Vận Hành CSDL Ngoại Vi (`@basancorp/plugin-data-source-external`)

Plugin `@basancorp/plugin-data-source-external` giải quyết bài toán cốt lõi: **Kết nối trực tiếp tới CSDL có sẵn của doanh nghiệp (Legacy Database, Website thương mại điện tử, ERP)** mà không cần di chuyển hay chuyển đổi dữ liệu, tuân thủ nguyên tắc **Single Source of Truth (SSOT)** và cơ chế **Live Direct Query (Truy vấn Trực tiếp Thời gian thực)**.

---

## 1. Các Tính Năng Doanh Nghiệp Trọng Yếu

1. **Chế Độ Chỉ Đọc Tuyệt Đối (Enforced Read-Only Guard)**:
   - Ngăn chặn triệt để mọi rủi ro làm hỏng CSDL nguồn từ phía NocoBase.
   - Ở tầng Driver/Session: Chạy lệnh `SET SESSION CHARACTERISTICS AS TRANSACTION READ ONLY;` (Postgres) ngay khi mở kết nối.
   - Ở tầng NocoBase Repository: Chặn đứng các hành động ghi (`create`, `update`, `destroy`, `bulkCreate`, `bulkUpdate`), trả về lỗi `403 Forbidden: External Data Source is in Read-Only mode`.
2. **Đồng Bộ Cấu Trúc 1-Chạm (1-Click Schema Drift Refresh)**:
   - Khi CSDL ngoài thêm cột, đổi kiểu dữ liệu hoặc thêm bảng mới, quản trị viên chỉ cần bấm **"Làm mới cấu trúc"** (`dataSources:refreshTableSchema`).
   - Giữ nguyên toàn bộ cấu hình giao diện UI, nhãn hiển thị và quyền truy cập đã thiết lập trên NocoBase cho các trường cũ.
3. **Hỗ Trợ PostgreSQL Schema Đa Tầng**:
   - Không bị giới hạn trong schema `public`, hỗ trợ chỉ định schema riêng biệt: `sales`, `hr`, `inventory`, `analytics`.
4. **Quản Trị Connection Pool Linh Hoạt**:
   - Tùy biến `pool.max`, `pool.min`, `acquireTimeout`, `idleTimeout` chống cạn kiệt tài nguyên kết nối của CSDL đích.

---

## 2. Bản Đồ Endpoint Quản Trị Data Source

```http
### 1. Khởi tạo kết nối nguồn dữ liệu ngoài mới
POST /api/dataSources:create
Authorization: Bearer <ADMIN_TOKEN>
Content-Type: application/json

{
  "key": "main_postgres_crm",
  "displayName": "Hệ thống CSDL Bán hàng (Postgres)",
  "type": "postgres",
  "options": {
    "host": "db.internal.basancorp.com",
    "port": 5432,
    "database": "sales_production",
    "username": "nocobase_readonly",
    "password": "SUPER_SECURE_PASSWORD",
    "schema": "public",
    "readOnly": true,
    "poolMax": 10,
    "poolMin": 2,
    "acquireTimeout": 30000,
    "idleTimeout": 10000,
    "ssl": false
  }
}

### 2. Kiểm tra kết nối (Ping / Test Connection)
POST /api/dataSources:testConnection
Authorization: Bearer <ADMIN_TOKEN>
Content-Type: application/json

{
  "type": "postgres",
  "options": {
    "host": "db.internal.basancorp.com",
    "port": 5432,
    "database": "sales_production",
    "username": "nocobase_readonly",
    "password": "SUPER_SECURE_PASSWORD"
  }
}

### 3. Nạp danh sách bảng từ CSDL ngoài (Introspect Tables)
GET /api/dataSources/main_postgres_crm/tables:list
Authorization: Bearer <ADMIN_TOKEN>

### 4. Nạp bảng cụ thể thành NocoBase Collection
POST /api/dataSources/main_postgres_crm/collections:load
Authorization: Bearer <ADMIN_TOKEN>
Content-Type: application/json

{
  "tableNames": ["customers", "orders", "order_items"]
}

### 5. Làm mới cấu trúc bảng khi có thay đổi (Schema Refresh)
POST /api/dataSources/main_postgres_crm/collections:refreshTableSchema
Authorization: Bearer <ADMIN_TOKEN>
Content-Type: application/json

{
  "tableName": "orders"
}
```

---

## 3. Tạo Quan Hệ Giữa Bảng Ngoài Và Bảng Nội Bộ NocoBase

Sau khi nạp các bảng ngoài thành Collections, AI Agent có thể thiết lập quan hệ liên kết với bảng nội bộ thông qua kỹ năng `nocobase-data-modeling`:

* **Quan hệ M2O (BelongsTo)**: Bảng nội bộ `contracts` liên kết tới bảng khách hàng ngoài `main_postgres_crm.customers`.
  - Khóa ngoại: `customerId` trên bảng `contracts`.
  - Khóa nguồn: `id` trên bảng `customers`.
* **Tra cứu trực tiếp (Zero Replication)**: Giao diện chi tiết hợp đồng hiển thị thông tin khách hàng thời gian thực trực tiếp từ database ngoài mà không cần đồng bộ bản sao định kỳ.

---

## 4. Checklist Thao Tác An Toàn

- [ ] **Luôn bật `readOnly: true`** đối với mọi CSDL sản xuất (Production Database) của bên thứ ba, trừ khi có yêu cầu nghiệp vụ bắt buộc phải ghi trực tiếp.
- [ ] Sử dụng tài khoản database có quyền hạn tối thiểu (chỉ cấp quyền `SELECT` ở mức PostgreSQL/MySQL role).
- [ ] Đặt `poolMax` phù hợp (thường là 5 - 10) để tránh chiếm hết connection pool của các ứng dụng chính.
- [ ] Chạy lệnh `testConnection` trước khi lưu cấu hình nguồn dữ liệu mới.
