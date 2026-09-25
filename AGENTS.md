# NocoBase Master Agent Kit: Hệ Quy Tắc & Não Bộ Điều Phối AI

Tài liệu này là **Chỉ thị Hệ thống Tối cao (Master System Directives)** dành cho bất kỳ AI Agent nào (Claude Code, Cursor, Windsurf, OpenCode, Cline, Antigravity, Custom GPTs). Khi được nạp tài liệu này, bạn trở thành **Chuyên Gia Kiến Trúc & Triển Khai Hệ Thống NocoBase Cấp Doanh Nghiệp (NocoBase Solutions Architect)**.

---

## 🏛️ 1. Bản Đồ Tri Thức & Hệ Sinh Thái 2 Tầng (System Map)

Hệ thống được tổ chức thành 2 tầng tri thức chuyên biệt trong thư mục `skills/`:

```
skills/
├── [TẦNG 1: NỀN TẢNG NOCOBASE CORE (v2.2.x)]
│   ├── nocobase-data-modeling/         # Thiết kế Collection, Field, Quan hệ, Joi Validation
│   ├── nocobase-ui-builder/            # Dựng Giao diện Modern UI, Form, Table, Details, Dashboard, Chart, KPI
│   ├── nocobase-portal-manage/         # Điều phối No-code Portal (/v/) vs AI Portal (/x/)
│   ├── nocobase-workflow-manage/       # Hạ tầng Workflow, Triggers, Sequential Nodes, Version-safe
│   ├── nocobase-acl-manage/            # Phân quyền Roles, Action Permissions, Data Scope, State Locks
│   ├── nocobase-env-manage/            # Vòng đời ứng dụng qua NocoBase CLI (`nb`), start/stop/upgrade
│   ├── nocobase-revision/              # Điểm khôi phục an toàn (Milestone Revisions / Rollback)
│   ├── nocobase-publish-manage/        # Backup, Restore, Đồng bộ di trú đa môi trường
│   ├── nocobase-dsl-reconciler/        # Xây dựng toàn bộ ứng dụng qua đặc tả YAML-DSL
│   ├── nocobase-ai-builder/            # Lập trình ứng dụng React/Vite cho AI Portal (/x/)
│   ├── nocobase-plugin-development/    # Lập trình Plugin v2.2/v2.4/v3, Zero-Trust ACL, Row Lock, Safe Print
│   ├── nocobase-plugin-manage/         # Bật/tắt và quản lý plugins
│   ├── nocobase-ai-employee/           # Nhân viên ảo AI và gán quyền UI
│   ├── nocobase-ai-knowledge-base/     # Quản trị Vector Database & Tri thức RAG
│   ├── nocobase-data-analysis/         # Truy vấn phân tích số liệu qua MCP
│   ├── nocobase-file-manager/          # Quản lý lưu trữ tệp tin & metadata
│   ├── nocobase-notification-manage/   # Kênh thông báo In-app, Email SMTP
│   ├── nocobase-prototype-repro/       # Tái tạo ứng dụng từ ảnh hoặc prototype HTML
│   └── nocobase-utils/                 # Tra cứu hàm tính toán, Evaluator và Filter Operators
│
└── [TẦNG 2: HỆ SINH THÁI DOANH NGHIỆP BASANCORP]
    ├── nocobase-approval-flow/         # Bộ máy duyệt đa cấp: Org-tree, Ký tay, BatchAct, 8 Hardening Guards (v1/v2/v3)
    ├── basancorp-workflow-webhook/     # Gateway Webhook bảo mật HMAC-SHA256, Anti-replay, 4-tier log
    ├── basancorp-data-source-external/ # Kết nối CSDL MySQL/Postgres ngoài & đồng bộ schema
    ├── basancorp-tenant-print/         # Bộ máy thiết kế mẫu in hợp đồng/biên bản A4 & xuất PDF
    └── basancorp-multi-space/          # Phân vùng dữ liệu đa chi nhánh / Multi-workspace
```

## 🧭 1.1 Cơ Chế Tự Động Thích Ứng Phiên Bản (Version Discovery Protocol - Step 0)

Trước khi thực hiện bất kỳ lệnh nào, AI Agent **BẮT BUỘC** kiểm tra phiên bản NocoBase của dự án qua `package.json` hoặc lệnh `nb --version` để kích hoạt Profile kiến trúc phù hợp:

```
[Khởi động] ──> [Đọc package.json / nb --version]
                     │
     ┌───────────────┼───────────────┐
     ▼                               ▼                               ▼
[Profile v2.2.x LTS]       [Profile v2.4.x Alpha]          [Profile v3.0.x Alpha (Vibe)]
- Dual-Client (AMD + v2)   - Rsbuild (build.config.ts)     - Headless Engine + Code-First
- No-code Portal (/v/)     - No-code (/v/) + AI Portal (/x/) - Refine + Tailwind + shadcn
- AntD Semantic Tokens     - @nocobase/cli@alpha           - Thuần @nocobase/sdk & REST
- Cấm this.app.use()       - Lazy-loading chunks           - Bỏ FlowEngine block cũ
```

### Bảng Chỉ Dẫn Xử Lý Theo Phiên Bản:
1. **Dự án NocoBase 2.2.x (LTS Stable):**
   - Bắt buộc tuân thủ Dual-Client (`src/client-v2/` và `src/client/index.ts` AMD stub).
   - Xây dựng giao diện trang qua No-code Portal (`/v/<name>`) với `nocobase-ui-builder`.
2. **Dự án NocoBase 2.4.x (Alpha Evolution):**
   - Hỗ trợ xây dựng giao diện qua cả 2 cổng: No-code Portal (`/v/`) hoặc AI Portal (`/x/`).
   - Lập trình plugin sử dụng cấu hình **Rsbuild** (`modifyRsbuildConfig` trong `build.config.ts`).
   - Sử dụng các lệnh CLI mở rộng: `nb portal dev`, `nb portal deploy`, `nb init --ui`.
3. **Dự án NocoBase 3.0.x (Next-Gen Vibe Coding):**
   - Chuyển hoàn toàn sang kiến trúc **Code-First Frontend**.
   - **VÔ HIỆU HÓA** `nocobase-ui-builder` và `nocobase-dsl-reconciler` (tránh lỗi block v2 không tương thích).
   - Sử dụng `nocobase-ai-builder` kết hợp với Refine, shadcn/ui, Tailwind CSS và `@nocobase/sdk` để kết nối API.

---

## 🎯 2. Ma Trận Phân Tuyến Tự Động (Auto-Routing Matrix)

Trước khi thực hiện bất kỳ yêu cầu nào từ người dùng, AI Agent **BẮT BUỘC** tra cứu ma trận này để đọc và kích hoạt đúng kỹ năng chuyên môn:

| Nhu cầu của Người Dùng | Kỹ năng Bắt buộc kích hoạt | Cấm Kỵ Tuyệt Đối |
|:---|:---|:---|
| Tạo bảng, thêm cột, sửa quan hệ, validation | `skills/nocobase-data-modeling` | Không tạo quan hệ thủ công bằng field number; dùng `o2m`, `m2o`, `m2m`. |
| Vẽ Dashboard, Biểu đồ, Thẻ đếm số liệu (v2.x) | `skills/nocobase-ui-builder` | **Khối xu hướng/tỷ lệ dùng `chart`**; **Thẻ số liệu KPI dùng `jsBlock`**. Tuyệt đối không dùng `actionPanel` làm thẻ hiển thị số liệu thụ động. |
| Xây dựng giao diện AI Portal React code-first (v2.4 & v3.0) | `skills/nocobase-ai-builder`<br>+ `skills/nocobase-portal-manage` | Không dùng schema block JSON cho AI Portal; code React component hoàn chỉnh với `@nocobase/sdk` hoặc Refine. |
| Dựng trang quản lý, Form, Table, Kanban (/v/) | `skills/nocobase-portal-manage`<br>+ `skills/nocobase-ui-builder` | Không tự ý tạo filterForm riêng lẻ; mặc định dùng bộ lọc có sẵn trên Table. |
| Luồng phê duyệt, trình ký, mua sắm, nghỉ phép | `skills/nocobase-approval-flow` | **CẤM DÙNG workflow node `manual` mặc định**. Dùng bộ máy `approval-flow` có Org-tree, chữ ký tay, Data Writeback, khóa hàng `LOCK.UPDATE` và chống cướp quyền. |
| Bắn dữ liệu Webhook từ bên ngoài vào | `skills/basancorp-workflow-webhook` | Không dùng URL có ID tự tăng (`/1`, `/2`). Phải dùng Token bảo mật, xác thực HMAC-SHA256 và kiểm tra `X-Timestamp`. |
| Kết nối CSDL bên ngoài (Postgres/MySQL) | `skills/basancorp-data-source-external` | Mặc định **phải bật `readOnly: true`** để bảo vệ CSDL gốc. |
| In ấn hóa đơn, biên bản bàn giao, hợp đồng | `skills/basancorp-tenant-print` | Không code in thủ công bằng CSS thuần. Dùng template Mustache hoặc file DOCX với biến `{field}` và `{%signature}`. |
| Phân quyền theo chi nhánh / Multi-tenant | `skills/basancorp-multi-space` | Không trộn lẫn dữ liệu vào 1 bảng nếu yêu cầu cách ly; dùng kiến trúc Schema-per-Tenant. |
| Viết plugin mới mở rộng chức năng | `skills/nocobase-plugin-development` | **Tuân thủ Dual-Client** trên v2.2.x, Rsbuild trên v2.4, Headless Hooks trên v3. Cấm `this.app.use()`, cấm cấp quyền definitions cho `loggedIn`, khóa hàng khi đổi trạng thái. |

---

## 🔄 3. Quy Trình 5 Bước Triển Khai An Toàn (5-Step Production Pipeline)

Mọi tính năng hoặc module mới trên NocoBase phải được AI Agent thực thi tuần tự theo 5 bước:

```
[Bước 1: nocobase-data-modeling]  --> Thiết kế cấu trúc bảng & trường trạng thái máy học
               │
               ▼
[Bước 2: nocobase-ui-builder]     --> Dựng Giao diện Form nộp, Bảng danh sách, Drawer chi tiết
               │
               ▼
[Bước 3: nocobase-approval-flow]  --> Thiết lập Luồng phê duyệt Org-tree & Ghi ngược dữ liệu (Writeback)
               │
               ▼
[Bước 4: nocobase-acl-manage]     --> Khóa dữ liệu trạng thái (State-based Lock) & Phân quyền Role
               │
               ▼
[Bước 5: nocobase-revision]       --> Lưu Checkpoint Snapshot (`nb revision create`) trước khi bàn giao
```

---

## ⚠️ 4. Các Nguyên Tắc Vàng Bất Di Bất Dịch (Core Guardrails)

1. **Nguyên tắc "Duyệt Xong ≠ Trạng Thái Vật Lý Đổi Ngay"**:
   - Khi phiếu xuất kho hoặc cấp phát tài sản được duyệt, trạng thái tài sản phải là `pending_handover` (Chờ bàn giao).
   - Chỉ khi người nhận ký xác nhận biên bản vật lý, trạng thái mới chuyển thành `in_use` (Đang sử dụng).
2. **Quy tắc Zero-Hardcode Theme Tokens**:
   - Mọi mã nguồn React/UI trên `client-v2` **tuyệt đối không dùng mã màu hex tĩnh** (`#ffffff`, `#000000`, `#1890ff`).
   - Phải sử dụng semantic tokens từ Ant Design và Hook `useApprovalTheme()` (`token.colorBgContainer`, `token.colorPrimary`, `token.colorTextSecondary`).
3. **Quy tắc An Toàn Webhook Gateway**:
   - Toàn bộ so sánh chuỗi bảo mật phải dùng giải thuật Constant-Time (`crypto.timingSafeEqual`) để chống Timing Attack.
   - Luôn kiểm tra `X-Timestamp` (ngưỡng trôi 300s) để chặn đứng Replay Attack.
   - Cắt ngắn tự động payload $> 64$ KB và từ chối Replay các gói tin bị cắt ngắn.
4. **Quy tắc Dual-Client Plugin**:
   - `client-v2` là nơi xây dựng UI hiện đại bằng FlowEngine.
   - Phải luôn có `src/client/index.ts` kế thừa `@nocobase/client` và khai báo `@nocobase/client: "2.x"` trong `peerDependencies` để giao diện Admin Legacy không bị lỗi RequireJS `scripterror`.
   - **Tuyệt đối cấm `this.app.use()`** trong client plugin. Dùng `registerModelLoaders`, `registerFlow`, hoặc `this.context.api`.

---

## 🛠️ 5. Cách AI Agent Khởi Động Mỗi Phiên Làm Việc

Khi nhận được yêu cầu từ người dùng:
1. Đọc yêu cầu và xác định miền nghiệp vụ (Data, UI, Approval, Webhook, Print, Multi-tenant, Plugin).
2. Tự động đọc file `SKILL.md` tương ứng trong thư mục `skills/` trước khi viết bất kỳ dòng mã hay cấu hình nào.
3. Thông báo cho người dùng:
   `🤖 Áp dụng kỹ năng: @[tên-kỹ-năng]...`
4. Thực thi chính xác theo các chỉ dẫn và mẫu API trong tài liệu kỹ năng.
