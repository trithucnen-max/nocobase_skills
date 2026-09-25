---
name: basancorp-workflow-webhook
description: >-
  Vận hành và cấu hình plugin Webhook Gateway của BasanCorp (@basancorp/plugin-workflow-webhook) trên NocoBase v2.
  Dùng khi cần tiếp nhận sự kiện webhook từ bên thứ ba (Cổng thanh toán MoMo/VNPay/Stripe, CRM, WordPress, Zalo),
  cấu hình bảo mật xác thực (HMAC-SHA256, API Key, Basic Auth, IP Whitelist, chống Replay Attack qua X-Timestamp),
  quản trị nhật ký webhook và bắn lại (1-click Replay).
version: 1.2.0
license: MIT
metadata:
  hermes:
    tags: [nocobase, webhook, security, hmac, anti-replay, gateway, basancorp]
    category: security-integration
    schema_version: "1.0"
    entrypoint: SKILL.md
  tags: [nocobase, basancorp, webhook, security, hmac, replay-attack, fintech, workflow]
---

# Kỹ Năng Vận Hành Webhook Gateway Doanh Nghiệp (`@basancorp/plugin-workflow-webhook`)

Plugin `@basancorp/plugin-workflow-webhook` là cổng tiếp nhận Webhook chuẩn Enterprise (Fintech Grade) cho NocoBase v2. Plugin này thay thế hoàn toàn trigger webhook đóng mã nguồn của bản Commercial tiêu chuẩn, mang lại khả năng chống tấn công thời gian (Timing Attack), chống phát lại (Replay Attack), loại bỏ IDOR và dọn dẹp nhật ký 4 tầng.

---

## 1. Bản Đồ Endpoint & Cơ Chế Hoạt Động

### 1.1. Cổng Tiếp Nhận Webhook Công Khai (Public Gateway)
- **URL Tiếp nhận**: `POST /api/webhook:trigger/:token`
  - `:token`: Chuỗi định danh bảo mật duy nhất ngẫu nhiên (UUIDv4/Hex) sinh ra khi tạo trigger node trong workflow.
  - ❌ **Chống IDOR**: Tuyệt đối không dùng ID tự tăng (`1`, `2`) làm định danh URL.

### 1.2. Quy Trình Thẩm Thấu Bảo Mật 5 Tầng (Security Gates)
Mọi request webhook gửi tới cổng tiếp nhận đều phải vượt qua 5 lớp phòng thủ trước khi kích hoạt Workflow:

```
[Bên gửi Webhook (MoMo, Stripe, CRM, Web)]
               │
               ▼
[Cổng Webhook Gateway: /api/webhook:trigger/:token]
  ├── 1. Method Guard: Bắt buộc HTTP POST (405 nếu là GET/PUT/DELETE)
  ├── 2. Token Guard: Tìm workflow theo Token bí mật (404 nếu không khớp)
  ├── 3. IP Whitelist: Kiểm tra danh sách dải IP cho phép (403 nếu ngoài danh sách)
  ├── 4. Timestamp & Anti-Replay: Kiểm tra header `X-Timestamp` (Chống phát lại trong ngưỡng trôi 300s)
  └── 5. Authentication Verification (Constant-Time Safe):
         ├── None: Mở không chứng thực
         ├── Basic Auth: `crypto.timingSafeEqual`
         ├── API Key Header: `X-Api-Key` / `X-Webhook-Token`
         └── HMAC-SHA256: `crypto.createHmac('sha256', secret).update(rawBody).digest('hex')`
               │
               ▼ (Vượt qua 5 tầng bảo vệ)
[Kích hoạt Workflow Execution & Ghi Nhật Ký Webhook Log]
```

---

## 2. Các Chế Độ Xác Thực & Cách Cấu Hình

### A. HMAC-SHA256 (Khuyến nghị chuẩn Fintech & Cổng thanh toán)
- **Header chữ ký**: `X-Signature`, `X-Hub-Signature-256`, hoặc header tùy chỉnh.
- **Tiêu chuẩn kiểm tra**:
  - Hệ thống tính toán mã băm HMAC trên `rawBody` bằng Secret Key đã cấu hình.
  - So sánh an toàn thời gian cố định (Constant-time comparison) bằng `crypto.timingSafeEqual(hashCalculated, hashReceived)` để chống Timing Attack.
- **Header mốc thời gian (Anti-Replay)**:
  - Header: `X-Timestamp` (epoch ms hoặc giây).
  - Ngưỡng cho phép (`tolerance`): Mặc định 300 giây (5 phút). Quá thời gian này gói tin bị từ chối với mã lỗi `401 Replay Attack Detected`.

### B. API Key
- Header: `X-Api-Key` hoặc `Authorization: Bearer <API_KEY>`.
- Hệ thống so sánh chuỗi băm SHA-256 an toàn trước crash đệm.

### C. Basic Authentication
- Header: `Authorization: Basic base64(user:pass)`.

### D. IP Whitelist
- Cấu hình dải IP đơn lẻ (`14.225.20.10`) hoặc dải CIDR (`192.168.1.0/24`). Hỗ trợ nhận diện Client IP thực qua header `X-Forwarded-For` khi đứng sau Nginx/Cloudflare.

---

## 3. Quản Trị Nhật Ký & Cơ Chế Tự Dọn Dẹp 4 Tầng (4-Tier Log Cleaner)

Dữ liệu webhook được lưu tại collection `webhookLogs`:

| Trường | Ý nghĩa |
|---|---|
| `workflowId` | Khóa ngoại trỏ đến workflow kích hoạt |
| `status` | `success` (200), `failed` (400, 401, 500) |
| `ip` | IP nguồn gửi webhook |
| `headers` | JSON toàn bộ HTTP request headers |
| `payload` | JSON body của request |
| `responseStatus` | Mã phản hồi HTTP trả về cho bên thứ ba |
| `responseBody` | Nội dung phản hồi |
| `isTruncated` | Đánh dấu `true` nếu payload $> 64$ KB (bị cắt gọn để bảo vệ đĩa) |

### Cơ chế tự động dọn dẹp (Auto-Pruning):
1. **Truncation Threshold (64 KB)**: Tự động cắt ngắn các payload vượt quá 64 KB, chống tràn bộ nhớ và phình database.
2. **Lọc chỉ lưu lỗi (`error_only`)**: Tùy chọn chỉ lưu log các request thất bại (4xx, 5xx) giúp tiết kiệm 95% dung lượng lưu trữ cho các hệ thống có lưu lượng lớn.
3. **Thời gian lưu trữ (TTL)**: Tự cấu hình lưu trong 7 ngày, 30 ngày hoặc 90 ngày.
4. **Xóa theo lô (Chunk-based Deletion)**: Tiến trình dọn dẹp nền định kỳ (Cron) xóa từng lô nhỏ (1.000 bản ghi/lô) kèm độ trễ 50ms, giúp PostgreSQL `autovacuum` liên tục mà không gây khóa bảng (table lock).

---

## 4. Cơ Chế Bắn Lại 1-Chạm (1-Click Replay)

Khi mạng gián đoạn hoặc CSDL bị quá tải khiến workflow xử lý thất bại, quản trị viên có thể kích hoạt lại sự kiện từ bảng nhật ký:

- **API Replay**:
  ```http
  POST /api/webhookLogs:replay
  Authorization: Bearer <ADMIN_TOKEN>
  Content-Type: application/json

  {
    "logId": 1420
  }
  ```
- **Quy tắc an toàn**:
  - ❌ **Chặn Replay Payload bị cắt ngắn**: Nếu `isTruncated === true`, hệ thống từ chối bắn lại và báo lỗi để tránh làm sai lệch dữ liệu kinh doanh do thiếu field.
  - ✅ Giữ nguyên toàn bộ `payload`, `headers`, `query` của gói tin gốc và chạy lại workflow trong ngữ cảnh cô lập.

---

## 5. Hướng Dẫn Sử Dụng Biến Webhook Trong Workflow Nodes

Sau khi nhận Webhook, các node tiếp theo trong Workflow truy xuất dữ liệu theo cú pháp chuẩn của NocoBase:

| Biến | Ý nghĩa | Ví dụ giá trị |
|---|---|---|
| `{{$context.data.body}}` | Toàn bộ payload JSON | `{"orderId": "ORD-99", "amount": 500000}` |
| `{{$context.data.body.orderId}}` | Lấy trường con trong body | `"ORD-99"` |
| `{{$context.data.headers['x-request-id']}}` | Lấy header cụ thể | `"req-123456"` |
| `{{$context.data.query.source}}` | Lấy tham số URL query | `"facebook_ads"` |

---

## 6. Checklist Kiểm Thử Trước Khi Vận Hành

- [ ] Sinh token ngẫu nhiên độ dài tối thiểu 32 ký tự, không dùng ID số.
- [ ] Thiết lập Secret Key phức tạp cho HMAC-SHA256 (tối thiểu 32 byte ngẫu nhiên).
- [ ] Bật kiểm tra `X-Timestamp` với ngưỡng trôi 300 giây trên các luồng tài chính/thanh toán.
- [ ] Cấu hình IP Whitelist cho các đối tác có IP tĩnh cố định (như VNPay, MoMo).
- [ ] Đặt thời gian lưu log hợp lý (7 ngày cho luồng thông thường, 30 ngày cho luồng thanh toán).
