# 🚀 NocoBase Master Agent Kit (Enterprise Solutions Suite)

> **Bộ tri thức & kỹ năng toàn diện dành cho AI Agent:** Biến mọi công cụ lập trình AI (Claude Code, Cursor, Windsurf, OpenCode, Cline, Antigravity) thành Chuyên gia Giải pháp NocoBase v2 & Hệ sinh thái Doanh nghiệp BasanCorp.

---

## 📦 Danh Mục 25 Kỹ Năng Đóng Gói

### 1. Nền Tảng NocoBase Core (20 Kỹ Năng)
1. **`nocobase-data-modeling`**: Thiết kế CSDL, collections, fields, quan hệ o2m/m2o/m2m, validation Joi.
2. **`nocobase-ui-builder`**: Dựng trang Modern UI, form, table, details, dashboard, chart, KPI card.
3. **`nocobase-portal-manage`**: Điều phối No-code Portal (`/v/`) và AI Portal (`/x/`).
4. **`nocobase-workflow-manage`**: Tự động hóa ngầm, trigger sự kiện bảng, cron, webhook nodes.
5. **`nocobase-acl-manage`**: Phân quyền vai trò, Data Scope, State-based Locks.
6. **`nocobase-env-manage`**: Quản lý vòng đời ứng dụng qua NocoBase CLI (`nb`).
7. **`nocobase-revision`**: Lưu checkpoint snapshot và rollback phiên bản an toàn.
8. **`nocobase-publish-manage`**: Backup, restore và di trú ứng dụng giữa các môi trường.
9. **`nocobase-dsl-reconciler`**: Xây dựng toàn bộ hệ thống qua tệp đặc tả YAML-DSL.
10. **`nocobase-ai-builder`**: Lập trình mã nguồn React cho AI Portal.
11. **`nocobase-plugin-development` (v2.4.0-adaptive.2)**: Phát triển plugin đa phiên bản (v2.2 LTS dual-client, v2.4 Rsbuild, v3 Headless/Refine), kiểm soát an ninh Zero-Trust ACL, khóa hàng Sequelize Transaction và kiến trúc in ấn an toàn.
12. **`nocobase-plugin-manage`**: Quản lý và bật/tắt plugins qua CLI.
13. **`nocobase-ai-employee`**: Khởi tạo và liên kết nhân viên AI vào giao diện nghiệp vụ.
14. **`nocobase-ai-knowledge-base-manager`**: Quản trị Vector DB và kho tri thức RAG.
15. **`nocobase-ai-manager`**: Quản trị AI Providers và các mô hình LLM.
16. **`nocobase-data-analysis`**: Phân tích dữ liệu kinh doanh qua giao thức MCP.
17. **`nocobase-file-manager`**: Quản lý file storage và metadata tệp đính kèm.
18. **`nocobase-notification-manage`**: Kênh thông báo In-app và Email SMTP.
19. **`nocobase-prototype-repro`**: Tái tạo ứng dụng trung thực từ bản vẽ/HTML prototype.
20. **`nocobase-utils`**: Tra cứu hàm công thức, biểu thức điều kiện và bộ lọc frontend.
### 2. Hệ Sinh Thái Doanh Nghiệp BasanCorp (5 Kỹ Năng Độc Quyền)
21. **`nocobase-approval-flow` (v2.1.0) [Enterprise Security & Concurrency Certified]**: Bộ máy duyệt đa cấp Org-tree, Ký tay số, Phê duyệt hàng loạt 1-click (BatchAct), Rút lại quyết định (Recall), Hối thúc duyệt (Urge), Nộp lại (Resubmit), Sinh mã định danh (Code Sequences), Ghi ngược dữ liệu (Writeback), tương thích đa phiên bản v1/v2/v3 và gia cố an ninh 8 chốt chặn (Row-level Lock, Anti-IDOR, Anti-Impersonation, Safe Print Blob Iframe).
22. **`basancorp-workflow-webhook` (v1.2.0)**: Gateway Webhook Fintech-grade, xác thực HMAC-SHA256, chống Replay Attack qua `X-Timestamp`, dọn dẹp log 4 tầng và 1-click Replay.
23. **`basancorp-data-source-external` (v1.1.0)**: Kết nối CSDL ngoại vi MySQL/PostgreSQL, chế độ Chỉ Đọc (Read-Only Guard) và 1-click đồng bộ cấu trúc (Schema Drift Sync).
24. **`basancorp-tenant-print` (v1.0.0)**: Bộ máy in kép: In nhiệt POS 80mm/58mm trực tiếp và xuất file Word DOCX / PDF hợp đồng, biên bản A4 kèm chữ ký số.
25. **`basancorp-multi-space` (v1.1.0)**: Quản trị đa không gian làm việc Multi-Tenant (Schema-per-Tenant), Ghost Login quản trị khẩn cấp và Tenant Clean View.

---

## 🌐 Khả Năng Tương Thích Đa Phiên Bản (Multi-Version Adaptive Matrix)

Bộ kit được thiết kế theo cơ chế **Đa hình tự thích ứng (Version-Adaptive Engine)**, cho phép AI Agent tự động phát hiện phiên bản NocoBase trong dự án (`package.json` hoặc `nb --version`) và kích hoạt Profile phù hợp:

| Phiên bản NocoBase | Trạng thái kiến trúc | Profile của AI Agent | Hướng dẫn kỹ thuật cốt lõi |
|:---|:---|:---|:---|
| **NocoBase 2.2.x (LTS Stable)** | Khuyên dùng cho Production | **Profile LTS (Dual-Client)** | Xây dựng giao diện qua No-code Portal (`/v/`). Phát triển plugin bắt buộc kiến trúc Dual-client: modern code trong `src/client-v2/` và stub `src/client/index.ts` cho v1 AMD loader. |
| **NocoBase 2.4.x (Alpha Evolution)** | Nhánh phát triển mở rộng | **Profile Rsbuild & Dual-Portal** | Hỗ trợ song song cả **No-code Portal (`/v/`)** và **AI Portal (`/x/`)**. Lập trình plugin tích hợp **Rsbuild** (`modifyRsbuildConfig` trong `build.config.ts`), tối ưu lazy-loading. |
| **NocoBase 3.0.x (Next-Gen Vibe Coding)** | Tiền phát hành (Code-First) | **Profile Headless & SDK** | Tách rời Backend Engine và Frontend. AI Agent tự do code frontend bằng Modern React + **Refine** + **Tailwind CSS** + **shadcn/ui** giao tiếp qua REST API hoặc `@nocobase/sdk`. Tự động vô hiệu hóa các schema block cũ của v2. |

---

## ⚡ Hướng Dẫn Sử Dụng Nhanh

### Cách 1: Cài đặt tự động bằng 1 lệnh Shell Script
Đứng tại thư mục dự án của bạn và chạy lệnh:
```bash
bash install.sh
```
Script sẽ tự động copy toàn bộ kỹ năng vào thư mục `.agents/skills/` hoặc `.claude/skills/` và tạo các file cấu hình tương thích với IDE đang mở.

### Cách 2: Sử dụng với Claude Code CLI
1. Copy thư mục `nocobase-master-agent-kit/` vào dự án của bạn.
2. Khởi chạy:
   ```bash
   claude
   ```
3. Claude Code sẽ tự động đọc `CLAUDE.md`, nạp `AGENTS.md` và toàn bộ 25 kỹ năng.

### Cách 3: Sử dụng với Cursor / Windsurf
Mở dự án trong Cursor hoặc Windsurf. IDE sẽ tự động kích hoạt `.cursorrules` hoặc `.windsurfrules`.

### Cách 4: Sử dụng với Hermes Agent (Nous Research / Open-source)
Gói kỹ năng tích hợp sẵn manifest `hermes.json` và khối `metadata.hermes` trên toàn bộ 25 skills.
- Cài đặt vào môi trường Hermes:
  ```bash
  bash install.sh --hermes
  ```
- Hoặc sao chép thư mục vào `~/.hermes/skills/nocobase`. Hermes Agent sẽ tự động lập chỉ mục (indexing), nhận diện công cụ và tự động kích hoạt kỹ năng tương ứng qua Function Calling.

### Cách 5: Sử dụng với Custom GPTs / Web Chatbot
Mở file `AGENTS.md`, copy toàn bộ nội dung và dán vào ô **Instructions (System Prompt)** của Custom GPT hoặc Dify.

---

## 📜 Bản Quyền & Giấy Phép
- **Bản quyền**: © 2026 BASANCORP Enterprise Solutions.
- **Tiêu chuẩn tương thích**: Hermes Agent Protocol v1/v2, Anthropic Claude Code, Cursor Rules, Windsurf Cascade.
- **Giấy phép**: MIT License.

