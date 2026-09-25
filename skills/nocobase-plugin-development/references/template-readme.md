# Mẫu Chuẩn Tài Liệu README.md Cho Plugin NocoBase (Template)

```markdown
# [Tên Plugin Tiếng Việt / English] (`@scope/plugin-name`)

> [Tóm tắt 1 câu về giá trị và mục tiêu của plugin]

[![NocoBase Version](https://img.shields.io/badge/nocobase-v2.x-blue.svg)](https://www.nocobase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📌 Tính Năng Nổi Bật
- **Tính năng 1**: Mô tả chi tiết tính năng chính.
- **Tính năng 2**: Mô tả các điểm đặc sắc, tự động hóa hoặc giao diện.
- **Tính năng 3**: Phân quyền, bảo mật hoặc tích hợp mở rộng.
- **Dual-Client Compatibility**: Tương thích cả giao diện quản trị cũ (RequireJS AMD) và giao diện hiện đại Client-v2 (`/v/`).

---

## 🚀 Hướng Dẫn Cài Đặt & Kích Hoạt

### Cách 1: Tải lên qua giao diện Web (Khuyên dùng)
1. Tải tập tin cài đặt `plugin-name-x.y.z.tgz`.
2. Đăng nhập vào NocoBase với tài khoản Quản trị viên.
3. Truy cập **Settings > Plugin Manager** (hoặc `https://your-domain.com/admin/settings/plugin-manager`).
4. Bấm **Upload plugin** và chọn file `.tgz`.
5. Sau khi tải lên thành công, tìm plugin trong danh sách và bấm **Enable**.

### Cách 2: Cài đặt qua dòng lệnh (CLI / Docker)
```bash
# Di chuyển vào thư mục ứng dụng
cd /path/to/nocobase

# Thêm plugin từ file tarball hoặc npm
yarn pm add /path/to/plugin-name-x.y.z.tgz

# Kích hoạt plugin
yarn pm enable @scope/plugin-name

# (Tùy chọn) Chạy migration nếu có
yarn nocobase upgrade
```

---

## 🧭 Hướng Dẫn Sử Dụng & Đường Dẫn Truy Cập

| Chức năng | Đường dẫn (URL) | Đối tượng sử dụng |
|---|---|---|
| **Trang chính tính năng** | `/v/my-plugin-page` | Toàn bộ nhân viên |
| **Khu vực quản trị cấu hình** | `/v/admin/settings/my-plugin-settings` | Quản trị viên hệ thống |

---

## 🛠️ Xử Lý Sự Cố Khẩn Cấp (Troubleshooting)

Nếu gặp lỗi xung đột script hoặc màn hình đỏ khi kích hoạt trên môi trường Docker/Coolify:
```bash
# Truy cập container terminal và chạy lệnh tắt plugin khẩn cấp
docker exec -it <container_name> yarn nocobase pm disable @scope/plugin-name

# Khởi động lại container
docker restart <container_name>
```

---

## 📄 Bản Quyền & Giấy Phép
Phát triển bởi **[Tên Công ty / Tác giả]**. Phát hành dưới giấy phép MIT License.
```
