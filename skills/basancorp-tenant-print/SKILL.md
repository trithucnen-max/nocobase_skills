---
name: basancorp-tenant-print
description: >-
  Vận hành và cấu hình plugin In Ấn & Xuất Mẫu Đa Năng của BasanCorp (@itngon/plugin-tenant-print) trên NocoBase v2.
  Dùng khi cần thiết kế mẫu in hóa đơn nhiệt (POS 80mm/58mm), biểu mẫu hợp đồng, biên bản bàn giao tài sản,
  phiếu thu/chi A4/A5 xuất file Word (DOCX) hoặc PDF, ánh xạ biến {{record.*}}, đọc số tiền thành chữ tiếng Việt
  và nhúng chữ ký số từ Approval Flow.
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [nocobase, print, pos, invoice, docx, pdf, handover, basancorp]
    category: document-automation
    schema_version: "1.0"
    entrypoint: SKILL.md
  tags: [nocobase, basancorp, print, invoice, pos, docx, pdf, barcode, qr-code, approval-signature]
---

# Kỹ Năng Vận Hành Bộ Máy In Ấn & Xuất Mẫu (`@itngon/plugin-tenant-print`)

Plugin `@itngon/plugin-tenant-print` là giải pháp in ấn tài liệu và xuất biểu mẫu chuyên sâu cho NocoBase v2. Plugin sở hữu **Kiến trúc Động cơ Kép (Dual-Engine Architecture)** đáp ứng trọn vẹn cả nhu cầu in nhiệt tốc độ cao tại quầy và xuất hồ sơ pháp lý phức tạp.

---

## 1. Kiến Trúc Động Cơ Kép (Dual-Engine Architecture)

```
                     ┌───────────────────────────────────────────────┐
                     │          @itngon/plugin-tenant-print          │
                     └───────────────────────┬───────────────────────┘
                                             │
                   ┌─────────────────────────┴─────────────────────────┐
                   │                                                   │
                   ▼                                                   ▼
       ┌───────────────────────────────┐               ┌───────────────────────────────┐
       │   Engine 1: In Nhanh HTML/POS │               │  Engine 2: Xuất Mẫu DOCX/PDF  │
       │   (Direct Browser Printing)   │               │     (Docxtemplater + PizZip)  │
       ├───────────────────────────────┤               ├───────────────────────────────┤
       │ • Hóa đơn nhiệt: Bill 80mm/58mm│              │ • Mẫu template Word (.docx)   │
       │ • Khổ in: Giấy A4, A5 ngang/dọc│              │ • Thẻ lặp bảng biểu {#items}  │
       │ • Tự động mở cửa sổ in window │               │ • Định dạng tiền tệ VND       │
       │ • Tương thích máy in nhiệt POS│               │ • Đọc số tiền thành chữ VN    │
       │ • Không cần cài driver phụ    │               │ • Xuất file DOCX / PDF tải về │
       └───────────────┬───────────────┘               └───────────────┬───────────────┘
                       │                                               │
                       └───────────────────────┬───────────────────────┘
                                               │
                                               ▼
                             ┌───────────────────────────────────┐
                             │    Hệ Sinh Thái Tích Hợp Sâu      │
                             ├───────────────────────────────────┤
                             │ • Nhúng Chữ ký số từ Approval Flow│
                             │ • Tự sinh QR Code thanh toán/tra  │
                             │ • Cách ly mẫu in theo từng Tenant │
                             └───────────────────────────────────┘
```

---

## 2. Quản Trị Danh Mục & Mẫu In (Print Templates)

Giao diện quản trị mẫu in đặt tại `/v/tenant-print/templates`:

| Trường cấu hình | Ý nghĩa & Tùy chọn |
|---|---|
| `name` | Tên mẫu: *Hóa đơn bán hàng*, *Hợp đồng cung cấp dịch vụ*, *Biên bản bàn giao tài sản* |
| `code` | Mã mẫu duy nhất: `INV_POS80`, `CONTRACT_A4`, `ASSET_HANDOVER` |
| `targetCollection` | Bảng CSDL nguồn: `orders`, `contracts`, `assetRequests` |
| `engineType` | `html_pos` (In nhanh trình duyệt) hoặc `docx_template` (Xuất file Word/PDF) |
| `paperSize` | `80mm`, `58mm`, `A4`, `A5`, `A4_landscape` |
| `content` | Mã nguồn HTML (với engine 1) hoặc File `.docx` tải lên (với engine 2) |
| `isDefault` | Đặt làm mẫu in mặc định cho bảng nguồn |

---

## 3. Cú Pháp Biến Dữ Liệu (Placeholder Syntax)

### A. Đối với Engine 1 (HTML / POS)
Sử dụng cú pháp template Mustache/Handlebars:
- Biến đơn lẻ: `{{code}}`, `{{customer.name}}`, `{{totalAmount}}`.
- Vòng lặp danh sách chi tiết (Sub-table):
  ```html
  {{#each items}}
  <tr>
    <td>{{productName}}</td>
    <td>{{quantity}}</td>
    <td>{{formatCurrency unitPrice}}</td>
    <td>{{formatCurrency amount}}</td>
  </tr>
  {{/each}}
  ```
- Định dạng tiền tệ & Ngày: `{{formatVND totalAmount}}`, `{{formatDate createdAt 'DD/MM/YYYY'}}`.

### B. Đối với Engine 2 (DOCX Template)
Tải file Word `.docx` lên, sử dụng cú pháp Docxtemplater:
- Biến trường: `{title}`, `{customer_name}`, `{contract_date}`.
- Lặp dòng bảng biểu: Bắt đầu bằng `{#items}` và kết thúc bằng `{/items}` ở 2 đầu dòng table trong Word.
- **Đọc số tiền thành chữ tiếng Việt**: Sử dụng helper `{total_amount_in_words}` (Ví dụ: `15.500.000` $\rightarrow$ *"Mười lăm triệu năm trăm nghìn đồng chẵn"*).
- **Nhúng Chữ Ký Tay Số**: Sử dụng thẻ ảnh `{%signature_image}` để chèn chữ ký tay điện tử trích xuất từ `approvalTasks.signatureUrl`.

---

## 4. Tích Hợp Nút In Vào Giao Diện NocoBase

Sau khi tạo mẫu in, tích hợp vào giao diện bảng dữ liệu bằng kỹ năng `nocobase-ui-builder`:

1. Mở trang danh sách hoặc chi tiết bản ghi (Table / Details Block).
2. Thêm Record Action dạng nút bấm:
   - Tên nút: **"In phiếu"** hoặc **"Xuất biên bản (PDF)"**.
   - Icon: `PrinterOutlined` hoặc `FilePdfOutlined`.
   - Action Handler: Kích hoạt action `tenantPrint:preview` hoặc `tenantPrint:download` kèm `templateId` và `recordId`.

---

## 5. Danh Mục Developer APIs

```http
### 1. Xem trước mẫu in (HTML Preview)
POST /api/tenantPrint:preview
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "templateCode": "INV_POS80",
  "recordId": 142
}

### 2. Xuất file DOCX / PDF
POST /api/tenantPrint:render
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "templateCode": "ASSET_HANDOVER",
  "recordId": 89,
  "format": "pdf" // 'docx' | 'pdf'
}
```
